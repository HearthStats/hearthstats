class Api::V3::ArenasController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_req

  respond_to :json

  def show
    api_response = {status: "success", data: ArenaRun.class_array(current_user.id) }

    render json: api_response
  end

  def new
     render json: { status: "fail", message: "Please update your uploader."}
  end
end
