class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    destroy_guest
    super

    if resource.save
      # Create Profile
      Profile.create(user_id:resource.id)

      begin
        c = Cindy.new "23.253.53.117", "cGF9DlbzfS0jBooMv5N3"
        c.subscribe "aQOe0RrtTXddPhL9p28929MA", resource.email
        c.subscribe "6V763uDbDJuEja62CUwTlthQ", resource.email
      rescue
      end
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
