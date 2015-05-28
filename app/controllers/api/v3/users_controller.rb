class Api::V3::UsersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def premium
    user = current_user
    if user.subscription_id.nil?
      api_response = {
        status: "error",
        message: "User not is not premium"
      }
    else
      api_response = {
        status: "success",
        user: user,
        aws_access_key: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_key: ENV['AWS_SECRET_ACCESS_KEY']
      }
    end
    render json: api_response
  end
end
