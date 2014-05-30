class ArenaRunsController < ApplicationController
  before_filter :authenticate_user!
  def index
    redirect_to arenas_url
  end
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
          redirect_to new_arena_url
        }
        format.json { head :no_content }
      end
    else
      format.html { render action: "new" }
      format.json { render json: @arenarun.errors, status: :unprocessable_entity }
    end
  end

  def end
    @arenarun = ArenaRun.find(session[:arenarunid])
  end

  def edit
    @arenarun = ArenaRun.find(params[:id])
    @arena = Match.new
    if current_user.id != @arenarun.user_id
      redirect_to root_url, alert: 'You are not authorized to edit that.'
    end
  end

  def update
    @arenarun = ArenaRun.find(params[:id])
    lastarena = @arenarun.matches.last
    if request.referer == end_arena_runs_url
      @arenarun.notes = lastarena.notes unless lastarena.nil?
      session[:arenarunid] = nil
      @arenarun.complete = true
    end

    respond_to do |format|
      if @arenarun.update_attributes(params[:arena_run])
        lastarena.notes = @arenarun.notes unless lastarena.nil?
        lastarena.save! unless lastarena.nil?
        format.html { redirect_to arenas_url, notice: 'Arena Run was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @arena = ArenaRun.find(params[:id])
    @arena.destroy

    respond_to do |format|
      format.html { redirect_to arenas_url, notice: 'Arena Run deleted.' }
      format.json { head :no_content }
    end
  end
end
