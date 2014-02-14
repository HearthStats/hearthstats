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
				# Required params:
				# :oppclass_id, :result_id, :coin
				# Optional params:
				# :notes

				arena_run = ArenaRun.where(user_id: @user.id, complete: false).last
				if arena_run.nil?
					arena_run = ArenaRun.new(user_id: @user.id, klass_id: @req[:klass_id])
					arena_run.save
				end
				arena = Match.new(@req)
        arena.user_id = @user.id
				if arena.save
          MatchRun.new(match_id: arena.id, arena_run_id: arena_run.id).save!
	        render json: {status: "success", data: arena}
	      else
	        render json: {status: "fail", message: arena.errors.full_messages}
	      end
			end
		end
	end
end
