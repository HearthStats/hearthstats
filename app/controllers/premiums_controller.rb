class PremiumsController < ApplicationController
  before_filter :authenticate_subs!, only: :report
  include SearchHelper
  def index
    if !signed_in?
      redirect_to new_user_session_path, 
        alert: "Please sign in before purchasing"
    end
  end

  def new
  end

  def create
    @amount = 699
    begin
      if current_user.customer_id.nil?
        customer = Stripe::Customer.create(
          email: current_user.email,
          card: params[:stripeToken],
          plan: "gold"
        )
        current_user.subscription_id = 1
        current_user.customer_id = customer.id
        current_user.save!
        current_user.add_role :early_sub
      else
        customer = Stripe::Customer.retrieve(current_user.customer_id)
        if params[:stripeToken].present?
          customer.card = params[:stripeToken]
        end
        current_user.subscription_id = 1
        customer.plan = "gold"
        current_user.add_role :early_sub
        current_user.save
        customer.save
      end
    rescue Stripe::CardError => e
    end
    redirect_to premiums_path, alert: e

  end

  def show
  end

  def stats
    params.reverse_merge!(default_options)
    search_params = default_params.merge(params[:q].reject{|k,v| v.blank?})

    @q = current_user.matches.ransack(params[:q]) # form needs ransack raw data
    @matches = current_user.matches
      .preload(:match_rank => :rank, :match_deck => :deck)
      .ransack(search_params).result
      .limit(params[:items])
      .order("#{params[:sort]} #{params[:order]}")
      .paginate(page: params[:page], per_page: params[:items])
  end

  def report
  end

  def gen_report
    if params["modules"].nil?
      redirect_to report_premiums_path, alert: "Please select at least one module" and return
    end
    mode_id = Mode::LIST.invert[params[:mode]]
    coin = [ params[:coin].to_i == 1, params[:no_coin].to_i == 0 ]
    user_klass_ids = []
    opp_klass_ids = []
    @modules_array = []
    Klass::LIST.each do |klass|
      user_klass_ids << klass[0] if params["user"][klass[1]].to_i == 1
      opp_klass_ids << klass[0] if params["opp"][klass[1]].to_i == 1
    end
    params["modules"].each do |mod|
      @modules_array << mod[0] if mod[1].to_i == 1
    end
    @matches = Match.where(user_id: current_user)
                    .where(mode_id: mode_id)
                    .where(created_at: params[:start_date].to_date.beginning_of_day..params[:end_date].to_date.end_of_day)
                    .where(coin: coin)
                    .where(klass_id: user_klass_ids)
                    .where(oppclass_id: opp_klass_ids)
                    .all
    get_modules(@matches, @modules_array, user_klass_ids, opp_klass_ids)
  end

  def get_modules(matches, modules, user_klass_ids, opp_klass_ids)
    args = { :matches => matches, 
             :user_klass_ids => user_klass_ids, 
             :opp_klass_ids => opp_klass_ids}
    graphs = GraphGenerator.new(args)
    modules.each do |method|
      instance_variable_set("@" + method, graphs.send(method))
    end
  end

  def stripe_cancel
    event_json = JSON.parse(request.body.read)
    customer_id = event_json["data"]["object"]["customer"]
    user = User.where(customer_id: customer_id).first
    if user.nil?
      render json: {status: 401, data: "User not found"} and return
    end
    if event_json["data"]["object"]["cancel_at_period_end"] == true
      user.update_attribute(:subscription_id, 2)
      response = user.email + "Cancelled"
    else
      response = user.email + "error in sub cancellation"
    end
    render json: {status: 200, data: response}
  end

  def stripe_delete
    event_json = JSON.parse(request.body.read)
    event_type = event_json["type"]
    customer_id = event_json["data"]["object"]["customer"]
    sub_status = event_json["data"]["object"]["status"]
    user = User.where(customer_id: customer_id).first
    if user.nil?
      render json: {status: 401, data: "User not found"} and return
    end
    if event_type == "customer.subscription.deleted" && sub_status == "canceled"
      user.update_attribute(:subscription_id, nil)
      user.remove_role :early_sub
      response = user.email + "Deleted"
    else
      response = user.email + "error in sub deletion"
    end
    render json: {status: 200, data: response}
  end

  def cancel
    begin
      customer = Stripe::Customer.retrieve(current_user.customer_id)
      unless customer.nil? || customer.respond_to?("deleted")
        subscription = customer.subscriptions.data[0]
        if subscription.status == "active"
          subscription.delete(:at_period_end => true)
        end
      end
    rescue Stripe::CardError => e
    end
    redirect_to premiums_path
  end
end
