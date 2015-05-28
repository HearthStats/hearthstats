class Api::V3::RegistrationsController < ApplicationController
  respond_to :json

  def create
    user = User.new(params[:user])
    if user.save
      render json: user.as_json(auth_token: user.authentication_token, email: user.email), status: :created
      return
    else
      warden.custom_failure!
      render json: user.errors, status: :unprocessable_entity
    end
  end
end
