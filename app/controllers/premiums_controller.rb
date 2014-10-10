class PremiumsController < ApplicationController
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
