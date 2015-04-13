class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    destroy_guest
    super

    if resource.save
      begin
        c = Cindy.new "http://news.hearthstats.net", "bM0U7Pvc9xrWW3VEtnhC"
        c.subscribe "Ntpx892i59vnutdwttp2zLIg", resource.email
      rescue
      end
    end
  end

  def update
    super
  end

  def destroy
    unless current_user.customer_id.nil?
      customer = Stripe::Customer.retrieve(current_user.customer_id)
      unless customer.nil? or customer.respond_to?('deleted')
        subscription = customer.subscriptions.data[0]
        if subscription.status == 'active'
          customer.cancel_subscription
        end
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
