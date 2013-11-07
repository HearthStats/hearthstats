class ProfilesController < ApplicationController
  def index
  	@user = current_user
  end

  def edit
  end

  def show
  	@user = User.find(params[:id])
  	respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
end
