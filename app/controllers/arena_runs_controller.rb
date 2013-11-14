class ArenaRunsController < ApplicationController
	def new
		@arenarun = ArenaRun.new
		@gamestoday = ArenaRun.where(user_id: current_user.id).where("created_at >= ?", Time.zone.now.beginning_of_day).count
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

	def edit
		@arenarun = ArenaRun.find(session[:arenarunid])
	end

	def update
    @arenarun = ArenaRun.find(session[:arenarunid])
		@arenarun.complete= true
		session[:arenarunid] = nil
    respond_to do |format|
      format.html { redirect_to arenas_url, notice: 'Arena Run Completed.'  }
      format.json { head :no_content }
    end
  end
end
