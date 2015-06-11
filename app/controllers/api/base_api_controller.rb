class Api::BaseApiController < ApplicationController
  respond_to :json
  skip_before_filter :verify_authenticity_token
end
