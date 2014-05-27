class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end
  
  def create
    destroy_guest
    super
    
    if resource.save
      Profile.new(user_id:resource.id).save!
    end
  end
  
  def update
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
