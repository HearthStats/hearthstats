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
    @arena = Arena.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @arena }
    end
  end

  # GET /arenas/new
  # GET /arenas/new.json
  def new
    @arena = Arena.new
    if session[:arenarunid]
    	@arenarun = ArenaRun.find(session[:arenarunid])
    else
	    @arenarun = ArenaRun.where(user_id: current_user.id, complete: false).last
	    session[:arenarunid]=@arenarun.id
	  end
	  @runwins = Arena.where(arena_run_id: session[:arenarunid], win: true).count
    @runloses = Arena.where(arena_run_id: session[:arenarunid], win: false).count
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @arena }
    end
  end

  # GET /arenas/1/edit
  def edit
    @arena = Arena.find(params[:id])
    canedit(@arena)
  end

  # POST /arenas
  # POST /arenas.json
  def create

    @arena = Arena.new(params[:arena])
    @arena.user_id = current_user.id
    @runwins = Arena.where(arena_run_id: session[:arenarunid], win: true).count
    @runloses = Arena.where(arena_run_id: session[:arenarunid], win: false).count
    if @runwins > 11 || @runloses > 2
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        if @arena.save
          @runwins = Arena.where(arena_run_id: session[:arenarunid], win: true).count
          @runloses = Arena.where(arena_run_id: session[:arenarunid], win: false).count
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
    @arena = Arena.find(params[:id])

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
    @arena = Arena.find(params[:id])
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
    @classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
  	@matches = Arena.where(user_id: current_user.id)
  	@arena_array = ArenaRun.classArray(current_user.id)
  end
end
