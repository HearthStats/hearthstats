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
    @matches = Match.where(:mode_id => 1, user_id: current_user.id)

    respond_to do |format|
      format.html # show.html.erb
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
    @arenarun = ArenaRun.where(user_id: current_user.id, complete: false).last
    @arena.klass_id = @arenarun.klass_id
    @arena.result_id = 2 if params[:match][:result_id].to_i == 0
    @arena.user_id = current_user.id
    @arena.mode_id = 1
    @arena.coin = params[:match][:coin].to_i.zero?
    @arena.season_id = current_season
    @runwins = @arenarun.matches.where(result_id: 1).count
    @runloses = @arenarun.matches.where(result_id: 2).count
    if @runwins > 11 || @runloses > 2
      render action: "new"
    else
      respond_to do |format|
        if @arena.save
          MatchRun.new(arena_run_id: params[:arena_run_id], match_id: @arena.id).save!
          @arenarun.notes = @arena.notes
          @arenarun.save!
          @runwins = @arenarun.matches.where(result_id: 1).count
          @runloses = @arenarun.matches.where(result_id: 2).count
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
      else
        format.html { render action: "edit" }
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
      format.js
    end
  end

  def archives
    @arenas = Arena.where(user_id: current_user.id).paginate(:page => params[:page], :per_page => 10).order('created_at DESC')
  end

  def stats

    # get all matches
    matches = Match.where(:mode_id => 1)

    # filter by number of days to show
    daysQuery = CGI.parse(request.query_string)['days'].first
    @daysFilter = daysQuery != nil && daysQuery != 'all' ? true : false
    if @daysFilter
     @daysFilter = daysQuery.to_s =~ /^[\d]+(\.[\d]+){0,1}$/ ? daysQuery.to_f : 30
     matches = matches.where('matches.created_at >= ?', @daysFilter.days.ago)
    else
      @daysFilter = "all"
    end

    # filter by first/second
    @firstFilter = CGI.parse(request.query_string)['first'].first
    if @firstFilter == "yes"
      matches = matches.where(coin: false)
    else
      if @firstFilter == "no"
        matches = matches.where(coin: true)
      else
        @firstFilter = ""
      end
    end

    # filter by mode
    @modeFilter = CGI.parse(request.query_string)['mode'].first
    if @modeFilter == "casual"
      matches = matches.where(mode_id: 2)
    else
      if @modeFilter == "ranked"
        matches = matches.where(mode_id: 3)
      else
        @modeFilter = ""
      end
    end

    # build win rates while playing each class
    personalMatches = matches.where(user_id: current_user.id)
    @personalWinRates = getClassWinRatesForMatches(personalMatches);
    @globalWinRates = getClassWinRatesForMatches(matches);

    @matches = matches
    # calculate number of games per class
    @classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    @numMatchesPersonal = Hash.new
    @numMatchesGlobal = Hash.new
    @classes.each_with_index do |c,i|
      @numMatchesGlobal.store(c, matches.where(klass_id: i+1).count)
      @numMatchesPersonal.store(c, personalMatches.where( klass_id: i+1).count)
    end

  end


  def quickentry
    @arena = Match.new(params[:match])
    @arenarun = ArenaRun.find(params[:arena_run_id])
    @arena.klass_id = @arenarun.klass_id
    @arena.user_id = current_user.id
    @arena.mode_id = 1
    @arena.coin = params[:match][:coin].to_i.zero?
    @arena.season_id = current_season
    if params[:commit] == "Add Win"
      @arena.result_id = 1
    elsif params[:commit] == "Add Defeat"
      @arena.result_id = 2
    else
      @arena.result_id = 3
    end
    if @arena.save
      MatchRun.new(arena_run_id: params[:arena_run_id], match_id: @arena.id).save!
      redirect_to arenas_url, notice: 'Arena was successfully created.'
    else
      redirect_to arenas_url, alert: 'Arena could not be created.'
    end
  end


  protected
  def getClassWinRatesForMatches(matches)
    winrates = Array.new
    (1..9).each_with_index do |c,i|
      classgames = matches.where( klass_id: c)
      wins = classgames.where(:result_id => 1).count
      totgames = classgames.count
      if totgames == 0
        winrates[i] = 0
      else
        winrates[i] = ((wins.to_f / totgames)*100).round(2)
      end
    end
    return winrates
  end

end
