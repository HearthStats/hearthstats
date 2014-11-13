class PremiumsController < ApplicationController
  before_filter :authenticate_subs!, only: :report
  def index
    if !signed_in?
      redirect_to new_user_session_path, 
        alert: "Please sign in before purchasing"
    end
  end

  def new
  end

  def create
    @amount = 499
    begin
      if current_user.customer_id.nil?
        customer = Stripe::Customer.create(
          email: current_user.email,
          card: params[:stripeToken],
          plan: "early"
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
        customer.plan = "early"
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

  def report
  end

  def gen_report
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
    get_modules(Match.all, @modules_array, user_klass_ids, opp_klass_ids)
  end

  def get_modules(matches, modules, user_klass_ids, opp_klass_ids)
    graphs = GraphGenerator.new(matches, user_klass_ids, opp_klass_ids)
    modules.each do |method|
      instance_variable_set("@" + method, graphs.send(method))
    end
  end

  def cancel
    begin
      customer = Stripe::Customer.retrieve(current_user.customer_id)
      unless customer.nil? || customer.respond_to?("deleted")
        subscription = customer.subscriptions.data[0]
        if subscription.status == "active"
          customer.cancel_subscription
          current_user.subscription_id = nil
          current_user.remove_role :early_sub
          current_user.save!
        end
      end
    rescue Stripe::CardError => e
    end
    redirect_to premiums_path
  end
end
