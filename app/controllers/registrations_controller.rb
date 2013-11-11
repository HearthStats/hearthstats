class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    super
    # gb = Gibbon::API.new("33bdb1440a0a40ab222881cb695ddcfb-us3")
    # Gibbon::API.throws_exceptions = false

    # gb.lists.subscribe({:id => "60f67fd447" , :email => {:email => params[:user][:email]} })
    # qwq = Gibbon::API.lists.list
    # raise

    if resource.save
      q = Profile.new
      q.user_id = resource.id
      q.save 

      gb = Gibbon::API.new("33bdb1440a0a40ab222881cb695ddcfb-us3")
      gb.throws_exceptions = false
      gb.lists.subscribe({:id => "60f67fd447" , :email => {:email => resource.email}, :double_optin => "false" })
    end
  end

  def update
    super
  end
end 