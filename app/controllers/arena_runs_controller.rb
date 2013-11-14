class ArenaRunsController < ApplicationController
	def new
		@arenarun = ArenaRun.new
	end

	def create
		@arenarun = ArenaRun.new(params[:arena_run])
		@arenarun.user_id = current_user.id

		if @arenarun.save
			respond_to do |format|
	      format.html { 
	      	session[:arenarunid] = @arenarun.id
	      	redirect_to new_arena_url 
	      }
	      format.json { head :no_content }
	    end
		else
			format.html { render action: "new" }
			format.json { render json: @arenarun.errors, status: :unprocessable_entity }
		end
	end
end
