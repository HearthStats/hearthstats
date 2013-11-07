class ProfilesController < ApplicationController
  def index
  	@user = current_user
  end

  def edit
  end

  def show
  	@user = User.find(params[:id])
  	@profile = @user.profile
  	recentgames(@user.id, 60)
  	respond_to do |format|
      format.html # show.html.erb
    end
  end
end
