class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
  	destroy_guest
    super
    c = Cindy.new "http://sendy.hearthstats.net", "cGF9DlbzfS0jBooMv5N3"
    if resource.save
    	# Create Profile
    	profile = Profile.new
      profile.user_id = resource.id
      profile.save

    	c.subscribe "aQOe0RrtTXddPhL9p28929MA", resource.email
    	c.subscribe "6V763uDbDJuEja62CUwTlthQ", resource.email
    end
  end

  def update
    super
  end

  private

  def destroy_guest
  	if session[:guest_user_id]
			User.find(session[:guest_user_id]).destroy
			session[:guest_user_id] = nil
		end
  end


end
