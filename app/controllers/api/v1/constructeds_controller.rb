module Api
	module V1
		class ConstructedsController < ApplicationController
			before_filter :restrict_access_api
			respond_to :json

			def show
				render :json => "hello"
			end

			def new
				req = ActiveSupport::JSON.decode(request.body).symbolize_keys
				@constructed = Constructed.new(req)
				if @constructed.save
	        render json: @user
	      else
	        render json: @constructed.errors
	      end
			end
		end
	end
end