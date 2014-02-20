module Api
	module V1
		class ArenaRunsController < ApplicationController
			before_filter :validate_userkey, :get_user_api
			skip_before_filter :get_user_api, :only => :end
			skip_before_filter :get_user_api, :only => :show
			respond_to :json

			def show
				# Required params:
				# None, just app key
				begin
			    last_arena_run = Hash.new
			    games = Hash.new

			    user = User.where(userkey: params[:userkey])[0]
			    last_run = ArenaRun.where(user_id: user.id).last
			    last_run.matches.each_with_index do |game, i|
			    	games[i+1] = {:oppclass_id => game.oppclass_id, :result_id => game.result_id, :coin => game.coin}
			    end
			    last_arena_run = {:klass_id => last_run.klass_id, :matches => games}
			  rescue
			  	api_response = {status: "error", message: "Error getting last arena run games"}
			  else
			    api_response = {status: "success", data: last_arena_run}
			  end
				render :json => api_response
			end

			def new
				# Required params:
				# params[:klass_id]

				userclass = Klass.where(:name => req[:class])[0]
				existing_runs = ArenaRun.where(user_id: 1, complete: false)
				existing_runs.update_all(:complete => true)
				arenarun = ArenaRun.new
				arenarun.user_id = @user.id
				arenarun.klass_id = userclass.id

				if arenarun.save!
	        render json: {status: "success", data: arenarun}
	      else
	        render json: {status: "fail", message: arenarun.errors.full_messages}
	      end
			end

			def end
				# Required params:
				# None, just app key
				# Optional params:
				# :notes, :gold, :dust

		    user = User.where(userkey: params[:userkey])[0]

				arena_run = ArenaRun.where(user_id: user.id, complete: false).last
				if arena_run.nil?
					render json: {status: "error", message: "No Active Arena Run"} and return
				end
				arena_run.complete = true

				if arena_run.save!
	        render json: {status: "success", data: arena_run}
	      else
	        render json: {status: "fail", message: arenarun.errors.full_messages}
	      end
			end

		end
	end
end
