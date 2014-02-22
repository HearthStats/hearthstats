class DecksController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :public]
  # GET /decks
  # GET /decks.json
  def index
    @decks = Deck.joins("LEFT OUTER JOIN unique_decks ON decks.unique_deck_id = unique_decks.id").where(:user_id => current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end

  # GET /decks/public
  # GET /decks/1.json
  def public
    #@decks = Deck.select('*').where("unique_deck_id IS NOT NULL").distinct(:unique_deck_id)
    @decks = Deck.where("unique_deck_id IS NOT NULL AND is_public = 1").joins(:unique_deck)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end

  # GET /decks/1
  # GET /decks/1.json
  def show
    @deck = Deck.find(params[:id])
    impressionist(@deck)

	  matches = @deck.matches.where(:mode_id => [2,3])

    # Deck parsing too hard
    # if @deck.decklink.blank?
    #   @message = "No deck link attatched to this deck yet <p>"
    # else
    #   @message = @deck.decklink_message
    # end

    # Win rates vs each class
    @deckrate = Array.new
    i = 0
    Klass.order("name").each do |c|
	    wins = matches.where(oppclass_id: c.id, result_id: 1).count
	    totgames = matches.where(oppclass_id: c.id).count
	    if totgames == 0
	    	@deckrate[i] = [0,"#{c.name}<br/>0 Games"]
	    else
		    @deckrate[i] = [((wins.to_f / totgames)*100).round(2), "#{c.name}<br/>#{totgames} Games"]
		  end
		  i = i + 1
	  end

	  # Going first vs 2nd
	  totgamesfirst = matches.where(coin: false).count
	  totgamessec = matches .where(coin: true).count
	  @firstrate = ((matches .where(coin: false, result_id: 1).count.to_f / totgamesfirst)*100).round(2)
	  @firstrate = @firstrate.nan? ? '0 games' : @firstrate.to_s() + '%'
	  @secrate = ((matches.where(coin: true, result_id: 1).count.to_f / totgamessec)*100).round(2)
	  @secrate = @secrate.nan? ? '0 games' : @secrate.to_s() + '%'

    #calculate deck winrate
    @winrate = 0
    if @deck.constructeds.count > 0
      @winrate = (matches.where(result_id: 1).count.to_f / @deck.constructeds.count * 100)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @deck }
    end
  end

  # GET /decks/new
  # GET /decks/new.json
  def new
    @deck = Deck.new
    @deck.is_public = true
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @deck }
    end
  end

  # GET /decks/1/edit
  def edit
    @deck = Deck.find(params[:id])
    @classes = Klass.all
    canedit(@deck)
  end

  # POST /decks
  # POST /decks.json
  def create
    @deck = Deck.new(params[:deck])
    @deck.user_id = current_user.id
    if current_user.guest?
    	@deck.is_public = false
    end
    respond_to do |format|
      if @deck.save
        format.html { redirect_to @deck, notice: 'Deck was successfully created.' }
        format.json { render json: @deck, status: :created, location: @deck }
      else
        format.html { render action: "new" }
        format.json { render json: @deck.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /decks/1
  # PUT /decks/1.json
  def update
    @deck = Deck.find(params[:id])
    @deck.constructeds.update_all(:deckname => params[:deck]['name'])
    expire_fragment(@deck)
    respond_to do |format|
      if @deck.update_attributes(params[:deck])
        format.html { redirect_to @deck, notice: 'Deck was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /decks/1
  # DELETE /decks/1.json
  def destroy
    @deck = Deck.find(params[:id])
		@deck.destroy
    respond_to do |format|
      format.html { redirect_to decks_url }
      format.json { head :no_content }
    end
  end

  def active_decks
    @activeDecks = Deck.where(:user_id => current_user.id, active: true)
    @myDecks = getMyDecks()

  end

  def submit_active_decks
  	saves = 0
		Deck.where(:user_id => current_user.id).update_all(:active => nil)
  	(1..9).each do |i|
  		if params[i.to_s].blank?
  			next
				saves += 1
  		end
  		deck = Deck.where(:user_id => current_user.id, :name => params[i.to_s])[0]
  		deck.slot = i
  		deck.active = true

  		if deck.save
				saves += 1
  		end
  	end
  	if saves == 9
			redirect_to active_decks_decks_path, notice: 'Active decks successfully updated.'
		else
			redirect_to active_decks_decks_path, error: 'Cannot Update Active Decks'
		end
  end

  private

  def getMyDecks()
    Deck.where(:user_id => current_user.id).order(:klass_id, :name).all
  end
end
