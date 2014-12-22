class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    destroy_guest
    super
  end

  def update
    super
  end

  def destroy
    customer = Stripe::Customer.retrieve(current_user.customer_id)
    unless customer.nil? or customer.respond_to?('deleted')
      subscription = customer.subscriptions.data[0]
      if subscription.status == 'active'
        customer.cancel_subscription
      end
    end
    super
  end

  private

  def destroy_guest
    if session[:guest_user_id]
      User.find(session[:guest_user_id]).delete
      session[:guest_user_id] = nil
    end
  end

end
