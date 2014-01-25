module Api
	module V1
		class ArenasController < ApplicationController
			before_filter :get_app_key, :get_user_api
			skip_before_filter :get_user_api, :only => :show
			respond_to :json

			def show
		    user = User.where(userkey: params[:userkey])
				api_response = {status: "success", data: ArenaRun.classArray(user[0].id) }

				render :json => api_response
			end

			def new
				# Required params:
				# :oppclass, :win, :gofirst
				# Optional params:
				# :notes

				arena_run = ArenaRun.where(user_id: @user[0].id, complete: false).last
				arena = Arena.new(@req)
				arena.arena_run_id = arena_run.id
				arena.userclass = arena_run.userclass
				if arena.save
	        render json: {status: "success", data: arena}
	      else
	        render json: {status: "fail", message: arena.errors.full_messages}
	      end
			end
		end
	end
end