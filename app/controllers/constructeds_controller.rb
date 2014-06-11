class ConstructedsController < ApplicationController
  before_filter :authenticate_user!
  # GET /constructeds
  # GET /constructeds.json
  def index
    params[:q]     ||= {}
    params[:items] ||= 20
    params[:days]  ||= 30
    params[:page]  ||= 1
    params[:sort]  ||= 'created_at'
    params[:order] ||= 'desc'

    @q = current_user.matches.where(mode_id: [2,3]).ransack(params[:q])
    @matches = @q.result.limit(params[:items])
    unless params[:days] == "all"
      @matches = @matches.where('created_at >= ?', params[:days].to_i.days.ago)
    end
    @matches = @matches.order("#{params[:sort]} #{params[:order]}")
    @matches = @matches.paginate(page: params[:page], per_page: params[:items])

    @winrate = @matches.present? ? (@matches.where(result_id: 1).count.to_f / @matches.count) * 100 : 0

    @constructeds = current_user.matches.where(mode_id: [2,3])
    @lastentry    = @constructeds.last
    @my_decks     = get_my_decks

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
    @lastentry = Match.where(user_id: current_user.id, mode_id: [2,3]).last
    @my_decks = get_my_decks()
  end

  # GET /constructeds/1/edit
  def edit
    @constructed = Match.find(params[:id])
    canedit(@constructed)
    @my_decks = get_my_decks()
  end

  # POST /constructeds
  # POST /constructeds.json
  def create
    @constructed = Match.new(params[:match])
    if params[:deckname].nil?
      redirect_to new_constructed_path, alert: 'Please create a deck first.' and return
    end

    # Find mode_id
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
    if params[:win].present?
      @constructed.result_id = 1
    elsif params[:defeat].present?
      @constructed.result_id = 2
    elsif params[:draw].present?
      @constructed.result_id = 3
    end
    respond_to do |format|
      if @constructed.save
        MatchDeck.new( deck_id: deck.id, match_id: @constructed.id ).save!
        delete_deck_cache!(deck)
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
    deck = Deck.where(user_id: current_user.id, name: params[:deckname])[0]
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
      if @constructed.update_attributes(params[:match])
        format.html { redirect_to constructeds_url, notice: 'Constructed was successfully updated.' }
        format.json { head :no_content }
        delete_deck_cache!(deck)
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
    params[:q]     ||= {}
    params[:days]  ||= 'all'
    
    # prevent searching for decks that are explicitly not active
    params[:q].delete(:deck_active_eq) if params[:q][:deck_active_eq] == "0"
    
    @q       = Match.where(mode_id: [2,3]).ransack(params[:q])
    @matches = @q.result
    
    unless params[:days] == "all"
      @matches = @matches.where('matches.created_at >= ?', params[:days].to_i.days.ago)
    end
    
    personal_matches    = @matches.where(user_id: current_user.id)
    @personal_win_rates = Match.winrate_per_class(personal_matches)
    @global_win_rates   = Match.winrate_per_class(@matches)
    
    @num_matches_global   = Match.matches_per_class(@matches)
    @num_matches_personal = Match.matches_per_class(personal_matches)
    
    @classes = Klass.list
  end
  
  private
  
  def delete_deck_cache!(deck)
    Rails.cache.delete('deck_stats' + deck.id.to_s)
  end
  
  def get_my_decks
    return Deck.joins(:klass)
      .where(user_id: current_user.id)
      .order("klasses.name, decks.name").all.compact
  end

end
