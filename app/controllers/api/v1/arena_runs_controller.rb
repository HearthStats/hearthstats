module Api
	module V1
		class ArenaRunsController < ApplicationController
			before_filter :restrict_access_api, :get_user_api
			skip_before_filter :get_user_api, :only => :end
			skip_before_filter :get_user_api, :only => :show
			respond_to :json

			def show
				# Required params:
				# None, just app key

		    last_arena_run = Hash.new
		    games = Hash.new

		    user = User.where(apikey: params[:key])
		    last_run = ArenaRun.where(user_id: user[0].id).last
		    last_run.arenas.each_with_index do |game, i|
		    	games[i+1] = {:oppclass => game.oppclass, :win => game.win, :coin => !game.gofirst }
		    end
		    last_arena_run = {:userclass => last_run.userclass, :matches => games}

				render :json => last_arena_run
			end

			def new
				# Required params:
				# params[:userclass]

				arenarun = ArenaRun.new
				arenarun.user_id = @user[0].id
				arenarun.userclass = @req[:userclass]

				if arenarun.save
	        render json: "Arena Run Created\n"
	      else
	        render json: arenarun.errors
	      end
			end

			def end
				# Required params:
				# None, just app key
				# Optional params:
				# :notes, :gold, :dust

		    user = User.where(apikey: params[:key])

				arena_run = ArenaRun.where(user_id: user[0].id, complete: false).last
				if arena_run.nil?
					render json: "No Active Arena Run \n" and return
				end
				arena_run.complete = true
				if arena_run.save
	        render json: "Arena Run Ended\n"
	      else
	        render json: arenarun.errors
	      end
			end

		end
	end
end