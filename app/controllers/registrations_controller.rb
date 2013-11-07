class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    super
    q = Profile.new
    q.user_id = User.last.id
    q.save

  end

  def update
    super
  end
end 