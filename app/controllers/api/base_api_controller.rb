class Api::BaseApiController < ApplicationController
  respond_to :json
  skip_before_filter :verify_authenticity_token
  skip_before_filter :protect_from_forgery
  before_filter :poop

  def poop
    p "poop it"
  end
end
