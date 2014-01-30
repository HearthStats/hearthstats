module Api
	module V1
		class ArenasController < ApplicationController
			before_filter :get_app_key, :get_user_api
			skip_before_filter :get_user_api, :only => :show
			respond_to :json

			def show
		    user = User.where(userkey: params[:userkey])[0]
				api_response = {status: "success", data: ArenaRun.classArray(user.id) }

				render :json => api_response
			end

			def new
				# Required params:
				# :oppclass, :win, :gofirst
				# Optional params:
				# :notes

				arena_run = ArenaRun.where(user_id: @user.id, complete: false).last
				if arena_run.nil?
					arena_run = ArenaRun.new(user_id: @user.id, userclass: @req[:userclass])
					arena_run.save
				end
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