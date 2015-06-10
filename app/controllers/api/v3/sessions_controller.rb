class Api::V3::SessionsController < ApplicationController
  before_filter :authenticate_user!, except: [:create, :destroy]
  before_filter :get_req
  before_filter :ensure_params_exist
  respond_to :json

  def new
    super
  end
  
  def create
    resource = User.find_for_database_authentication(email: @req[:user_login]["email"])
    return invalid_login_attempt unless resource

    if resource.valid_password?(@req[:user_login]["password"])
      sign_in(:user, resource)
      resource.ensure_authentication_token!
      render json: {success: true, auth_token: resource.authentication_token, email: resource.email, userkey: resource.userkey}
      return
    end
    invalid_login_attempt
  end

  def destroy
    resource = User.find_for_database_authentication(email: @req[:user_login]["email"])
    resource.authentication_token = nil
    resource.save
    render json: {success: true}
  end

  protected
  def ensure_params_exist
    return unless @req[:user_login].blank?
    render json: {success: false, message: "missing user_login parameter"}, status: 422
  end

  def invalid_login_attempt
    render json: {success: false, message: "Error with your login or password"}, status: 401
  end
end
