class ArenasController < ApplicationController
  before_filter :authenticate_user!
  # GET /arenas
  # GET /arenas.json
  def index
    @arenaruns = ArenaRun.where(user_id: current_user.id).paginate(:page => params[:page], :per_page => 10).order('created_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @arenas }
    end
  end

  # GET /arenas/1
  # GET /arenas/1.json
  def show
    @arena = Match.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @arena }
    end
  end

  # GET /arenas/matches
  # GET /arenas/matches
  def matches
    @matches = Match.where(:mode_id => 1)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @arena }
    end
  end

  # GET /arenas/new
  # GET /arenas/new.json
  def new
    @arena = Match.new

		# Get last arena run
    @arenarun = ArenaRun.where(user_id: current_user.id, complete: false).last

  	# Redirect back to page is no current arena run
  	if @arenarun.nil?
  		redirect_to arenas_url, alert: 'No active arena run.' and return
  	end

    session[:arenarunid] = @arenarun.id
    runwins = @arenarun.matches.where(result_id: 1).count
    runloses = @arenarun.matches.where(result_id: 2).count
    if runwins > 11 || runloses > 2
      @arenarun.complete = true
      @arenarun.save!
    end
	  respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /arenas/1/edit
  def edit
    @arena = Match.find(params[:id])
    canedit(@arena)
  end

  # POST /arenas
  # POST /arenas.json
  def create

    @arena = Match.new(params[:match])
    @arena.result_id = 2 if params[:match][:result_id].to_i == 0
    @arena.user_id = current_user.id
    @arena.mode_id = 1
    @arena.coin = params[:match][:coin].to_i.zero?
    @arena.season_id = current_season
    @runwins = ArenaRun.find(session[:arenarunid]).matches.where(result_id: 1).count
    @runloses = ArenaRun.find(session[:arenarunid]).matches.where(result_id: 2).count
    if @runwins > 11 || @runloses > 2
      render action: "new"
    else
      respond_to do |format|
        if @arena.save
          MatchRun.new(arena_run_id: params[:arena_run_id], match_id: @arena.id).save!
          @runwins = ArenaRun.find(session[:arenarunid]).matches.where(result_id: 1).count
          @runloses = ArenaRun.find(session[:arenarunid]).matches.where(result_id: 2).count
          format.html { redirect_to new_arena_url, notice: 'Arena was successfully created.' }
          format.js
        else
          format.html { render action: "new" }
          format.js
        end
      end
    end
  end

  # PUT /arenas/1
  # PUT /arenas/1.json
  def update
    @arena = Match.find(params[:id])
    @arena.result_id = params[:win].to_i
    @arena.coin = params[:other][:gofirst].to_i.zero?
    @arena.oppclass_id = params[:match][:oppclass_id]
    respond_to do |format|
      if @arena.update_attributes(params[:arena])
        format.html { redirect_to arenas_url, notice: 'Arena was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @arena.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arenas/1
  # DELETE /arenas/1.json
  def destroy
    @arena = Match.find(params[:id])
    @arena.destroy

    respond_to do |format|
      format.html { redirect_to arenas_url }
      format.json { head :no_content }
    end
  end

  def archives
    @arenas = Arena.where(user_id: current_user.id).paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
  end

  def stats
  	@matches = Arena.where(user_id: current_user.id)
  	@arena_array = ArenaRun.classArray(current_user.id)
  end
end
