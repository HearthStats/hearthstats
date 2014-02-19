module Api
	module V1
		class ArenasController < ApplicationController
			before_filter :validate_userkey, :get_user_api
			skip_before_filter :get_user_api, :only => :show
			respond_to :json

			def show
		    user = User.where(userkey: params[:userkey])[0]
				api_response = {status: "success", data: ArenaRun.classArray(user.id) }

				render :json => api_response
			end

			def new
				 render json: { status: "fail", message: "Please update your uploader."}
      end
		end
	end
end
