class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout

  private

  def layout
    # only turn it off for login pages:
    is_a?(Devise::SessionsController) ? false : "application"
    # or turn layout off for every devise controller:
    !devise_controller? && "application"
  end

  def canedit(entry)
  	if current_user.id != entry.user_id
      redirect_to root_url, notice: 'You are not authorized to edit that.'
    end  	
  end
end
