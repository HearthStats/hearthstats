module Api
	module V1
		class ArenaRunsController < ApplicationController
			before_filter :restrict_access_api, :get_user_api
			skip_before_filter :get_user_api, :only => [:end]
			respond_to :json

			def show
				render :json => CGI.parse(request.query_string)
			end

			def new
				# Required params:
				# params[:userclass]

				@arenarun = ArenaRun.new
				@arenarun.user_id = @user[0].id
				@arenarun.userclass = @req[:userclass]

				if @arenarun.save
	        render json: "Arena Run Created\n"
	      else
	        render json: @arenarun.errors
	      end
			end

			def end
				# Required params:
				# None, just app key
				# Optional params:
				# :notes

		    @user = User.where(apikey: params[:key])

				arena_run = ArenaRun.where(user_id: @user[0].id, complete: false).last
				if arena_run.nil?
					render json: "No Active Arena Run \n" and return
				end
				arena_run.complete = true
				if arena_run.save
	        render json: "Arena Run Ended\n"
	      else
	        render json: @arenarun.errors
	      end
			end

		end
	end
end