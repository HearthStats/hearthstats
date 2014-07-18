class ConstructedsController < ApplicationController
  before_filter :authenticate_user!

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

    @last_deck = @matches.last.try(:deck)
    @my_decks = get_my_decks

    respond_to do |format|
      format.html
      format.json { render json: @constructeds }
    end
  end

  def show
    @constructed = Match.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @constructed }
    end
  end

  def new
    @my_decks = get_my_decks
    
    if @my_decks.blank?
      redirect_to new_deck_path, notice: "Please create a deck first."
    else
      @constructed = Match.new
      @lastentry   = Match.where(user_id: current_user.id, mode_id: [2,3]).last
    end
  end

  def edit
    @constructed = Match.find(params[:id])
    canedit(@constructed)
    @my_decks = get_my_decks
  end

  def create
    if params[:deckname].nil?
      redirect_to new_constructed_path, alert: 'Please create a deck first.'
      return
    end

    deck = Deck.where(name: params[:deckname], user_id: current_user.id ).first
    unless deck
      redirect_to new_constructed_path, alert: 'Unknown deck'
      return
    end
    
    # Find mode_id
    rank = params[:other].try(:[], :rank)
    if rank == "Ranked"
      mode_id = 3
    elsif rank == "Casual"
      mode_id = 2
    else
      redirect_to constructeds_path, alert: 'Mode Error'
      return
    end
    
    @constructed = Match.new(params[:match])
    @constructed.mode_id = mode_id
    @constructed.coin = params[:other][:gofirst].to_i.zero?

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
        MatchDeck.create( deck_id: deck.id, match_id: @constructed.id )
        delete_deck_cache!(deck)
        format.html { redirect_to constructeds_path, notice: 'Constructed was successfully created.' }
        format.json { render json: @constructed, status: :created, location: @constructed }
      else
        @my_decks = get_my_decks
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

    @q       = Match.where(mode_id: [2,3]).ransack(params[:q])
    @matches = @q.result

    unless params[:days] == "all"
      @matches = @matches.where('matches.created_at >= ?', params[:days].to_i.days.ago)
    end

    # Personal Stats
    @personal_matches    = @matches.where(user_id: current_user.id)
    @personal_win_rates = Match.winrate_per_class(@personal_matches)
    @num_matches_personal = Match.matches_per_class(@personal_matches)

    # Global Stats
    global_stats = Rails.cache.fetch('con_global_stats', expires_in: 12.hours) do
      [ Match.matches_per_class(@matches), 
        Match.winrate_per_class(@matches) ]
    end
    @num_matches_global   = global_stats[0]
    @global_win_rates   =  global_stats[1]

    @classes = Klass.list
  end

  private

  def delete_deck_cache!(deck)
    Rails.cache.delete('deck_stats' + deck.id.to_s)
  end

  def get_my_decks
    Deck.joins(:klass)
        .where(user_id: current_user.id)
        .order("klasses.name, decks.name").all.compact
  end

end
