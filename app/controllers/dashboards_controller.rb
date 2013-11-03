class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  def race
  	@matches = Arena.where(user_id: current_user.id, userclass: params[:race])
  end

  def index
  	@arena = Arena.where(user_id: current_user.id).find(:all, :order => "id desc", :limit => 5).reverse
  	@constructed = Constructed.where(user_id: current_user.id).find(:all, :order => "id desc", :limit => 5).reverse
  end
end