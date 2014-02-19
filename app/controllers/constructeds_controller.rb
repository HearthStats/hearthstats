class ConstructedsController < ApplicationController
  before_filter :authenticate_user!
  # GET /constructeds
  # GET /constructeds.json
  def index
    
    @items = CGI.parse(request.query_string)['items'].first
    if @items.nil? || !((Float(@items) rescue false))
      @items = 20
    end    
    
    @constructeds = Match.where(user_id: current_user.id, mode_id: [2,3]).paginate(:page => params[:page], :per_page => @items).order('created_at DESC')
    @constructed = Match.new
    @lastentry = Match.where(user_id: current_user.id, mode_id: [2,3]).last
    @myDecks = getMyDecks()
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @constructeds }
    end
  end

  # GET /constructeds/1
  # GET /constructeds/1.json
  def show
    @constructed = Match.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @constructed }
    end
  end

  # GET /constructeds/new
  # GET /constructeds/new.json
  def new
  	if Deck.where(user_id: current_user.id).count == 0
  		redirect_to new_deck_path, notice: "Please create a deck first."
  	end
    @constructed = Match.new
    @lastentry = Match.where(user_id: current_user.id).last
    @myDecks = getMyDecks()
  end

  # GET /constructeds/1/edit
  def edit
    @constructed = Match.find(params[:id])
    canedit(@constructed)
    @myDecks = getMyDecks()
  end

  # POST /constructeds
  # POST /constructeds.json
  def create
    @constructed = Match.new(params[:match])
    if params[:deckname].nil?
      redirect_to new_constructed_path, alert: 'Please create a deck first.' and return
    end

    # Find ranked_id
    if params[:other][:rank] == "Ranked"
      mode_id = 3
    elsif params[:other][:rank] == "Casual"
      mode_id = 2
    else
      redirect_to constructeds_path, alert: 'Mode Error' and return
    end
    @constructed.mode_id = mode_id
    @constructed.coin = params[:other][:gofirst].to_i.zero?

    deck = Deck.where( name: params[:deckname], user_id: current_user.id ).first
    @constructed.klass_id = deck.klass_id
    @constructed.user_id = current_user.id
    if params[:commit] == "Add Win"
      @constructed.result_id = 1
    elsif params[:commit] == "Add Defeat"
      @constructed.result_id = 2
    else
      @constructed.result_id = 3
    end
    respond_to do |format|
      if @constructed.save
        MatchDeck.new( deck_id: deck.id, match_id: @constructed.id ).save!
        format.html { redirect_to constructeds_path, notice: 'Constructed was successfully created.' }
        format.json { render json: @constructed, status: :created, location: @constructed }
      else
        format.html { render action: "new" }
        format.json { render json: @constructed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /constructeds/1
  # PUT /constructeds/1.json
  def update
    @constructed = Match.find(params[:id])
    deck = Deck.where(:user_id => current_user.id, :name => params[:deckname])[0]
    matchdeck = @constructed.match_deck
    matchdeck.deck_id = deck.id
    matchdeck.save!
    @constructed.klass_id = deck.klass_id
    @constructed.result_id = params[:win].to_i

    # Find ranked_id
    if params[:other][:rank] == "Ranked"
      mode_id = 3
    elsif params[:other][:rank] == "Casual"
      mode_id = 2
    else
      redirect_to constructeds_path, alert: 'Mode Error' and return
    end
    @constructed.mode_id = mode_id
    @constructed.coin = params[:other][:gofirst].to_i.zero?
    respond_to do |format|
      if @constructed.update_attributes(params[:constructed])
        format.html { redirect_to constructeds_url, notice: 'Constructed was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @constructed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /constructeds/1
  # DELETE /constructeds/1.json
  def destroy
    @constructed = Match.find(params[:id])
    @constructed.destroy
    respond_to do |format|
      format.html { redirect_to constructeds_url }
      format.json { head :no_content }
    end
  end

  def stats

    # get all matches
    matches = Match.joins(:deck).where(:mode_id => [2,3])

    # filter by number of days to show
    daysQuery = CGI.parse(request.query_string)['days'].first
    @daysFilter = daysQuery == "all" ? false : true
    if @daysFilter
     @daysFilter = daysQuery.to_s =~ /^[\d]+(\.[\d]+){0,1}$/ ? daysQuery.to_f : 30
     matches = matches.where('matches.created_at >= ?', @daysFilter.days.ago)
    else
      @daysFilter = "all"
    end

    # filter by first/second
    @firstFilter = CGI.parse(request.query_string)['first'].first
    if @firstFilter == "yes"
      matches = matches.where(gofirst: true)
    else
      if @firstFilter == "no"
        matches = matches.where(gofirst: false)
      else
        @firstFilter = ""
      end
    end

    # filter by mode
    @modeFilter = CGI.parse(request.query_string)['mode'].first
    if @modeFilter == "casual"
      matches = matches.where(rank: "casual")
    else
      if @modeFilter == "ranked"
        matches = matches.where(rank: "ranked")
      else
        @modeFilter = ""
      end
    end

    # build win rates while playing each class
    personalMatches = matches.where(user_id: current_user.id)
    @personalWinRates = getClassWinRatesForMatches(personalMatches);
    @globalWinRates = getClassWinRatesForMatches(matches);

    # calculate number of games per class
    @classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    @numMatchesPersonal = Hash.new
    @numMatchesGlobal = Hash.new
    @classes.each_with_index do |c,i|
      @numMatchesGlobal.store(c, matches.where(decks: { race: c}).count)
      @numMatchesPersonal.store(c, personalMatches.where(decks: { race: c}).count)
    end

  end

  protected
  def getClassWinRatesForMatches(matches)
    @classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    winrates = Array.new
    @classes.each_with_index do |c,i|
      classgames = matches.where(decks: { race: c})
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

  def getMyDecks()
    return Deck.joins(:klass)
      .where(:user_id => current_user.id)
      .order("klasses.name, decks.name").all
  end

end
