module Api
	module V1
		class ArenasController < ApplicationController
			before_filter :restrict_access_api
			respond_to :json

			def show
				render :json => "hello"
			end

			def new
				req = ActiveSupport::JSON.decode(request.body).symbolize_keys
				arena_run_id = ArenaRun.where(user_id: req[:user_id], complete: false).last.id
				@arena = Arena.new(req)
				@arena.arena_run_id = arena_run_id
				if @arena.save
	        render json: "Success\n"
	      else
	        render json: @arena.errors
	      end
			end
		end
	end
end