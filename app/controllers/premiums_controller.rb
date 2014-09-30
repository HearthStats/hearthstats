class PremiumsController < ApplicationController
  def index
    if current_user.nil?
      redirect_to new_user_registration_path, alert: "You must sign up before purchasing premium subscription"
    end
  end

  def new
  end

  def create
    @amount = 499
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
    end

    redirect_to premiums_path
  end

  def show
  end

  def cancel
    customer = Stripe::Customer.retrieve(current_user.customer_id)
    unless customer.nil? || customer.respond_to?("deleted")
      subscription = customer.subscriptions.data[0]
      if subscription.status == "active"
        customer.cancel_subscription
        current_user.subscription_id = nil
        current_user.save!
      end
    end
    rescue Stripe::StripeError => e
      logger.error "Stripe Error: " + e.message
      errors.add :base, "Unable to cancel your subscription. #{e.message}."
  end
end
