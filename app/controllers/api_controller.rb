class ApiController < ApplicationController

	def show
		render :json => "hello"
	end

	def new
		req = ActiveSupport::JSON.decode(request.body).symbolize_keys

		render :json => req[:username]
	end
end