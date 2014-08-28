class Api::V1::ConstructedsController < ApplicationController
  before_filter :validate_userkey, :get_user_api
  skip_before_filter :get_user_api, only: :show
  respond_to :json

  def show
    @user = User.where(userkey: params[:userkey])[0]
    render json: @user.matches.where(mode_id: [2,3])
  end

  def new
    render json: { status: "fail", message: "Please update your uploader."}
  end
end
