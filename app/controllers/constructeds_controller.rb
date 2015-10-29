class ConstructedsController < ApplicationController
  include SearchHelper

  before_filter :authenticate_user!, except: :win_rates

  def index
    params.reverse_merge!(default_options)
    search_params = default_params.merge(params[:q].reject{|k,v| v.blank?})

    @q = current_user.matches.ransack(params[:q]) # form needs ransack raw data
    @matches = current_user.matches
      .where(mode_id: [Mode::CASUAL, Mode::RANKED, Mode::FRIENDLY])
      .preload(:match_rank => :rank, :match_deck => :deck)
      .ransack(search_params).result
      .limit(params[:items])
      .order("#{params[:sort]} #{params[:order]}")
      .paginate(page: params[:page], per_page: params[:items])

    @winrate = calculate_winrate(@matches)

    @my_decks = get_my_decks
    @last_deck = current_user.matches
      .where(mode_id: [Mode::CASUAL, Mode::RANKED]).last.try(:deck)

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

  def quick_create
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
        @constructed.__elasticsearch__.index_document
        MatchDeck.create( deck_id: deck.id, match_id: @constructed.id )
        format.js
      else
      end
    end
  end


  def create
    if params[:deck_id].nil?
      redirect_to new_constructed_path, alert: 'Please create a deck first.'
      return
    end

    @deck = Deck.find(params[:deck_id])
    unless @deck
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

    @constructed.klass_id = @deck.klass_id
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
        MatchDeck.create(deck_id: @deck.id, 
                         match_id: @constructed.id,
                         deck_version_id: @deck.deck_versions.last.try(:id)
                        )
        format.html { redirect_to constructeds_path, notice: 'Constructed was successfully created.' }
        format.json { render json: @constructed, status: :created, location: @constructed }
        format.js
      else
        @my_decks = get_my_decks
        format.html { render action: "new" }
        format.json { render json: @constructed.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /constructeds/1
  # PUT /constructeds/1.json
  def update
    @constructed = Match.find(params[:id])
    deck = Deck.find(params[:deck_id])
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

    @q       = Match.where(mode_id: [2,3], season_id: current_season).ransack(params[:q])
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

  def reset
    current_user.matches.where(mode_id: [2,3]).delete_all
    redirect_to constructeds_path, notice: "All constructed matches deleted"
  end

  def win_rates
    win_rate = Rails.cache.read("con#wr_rate-#{params[:klass_id]}")
    render json: win_rate
  end

  private

  def delete_deck_cache!(deck)
    Rails.cache.delete('deck_stats' + deck.id.to_s)
  end

  def get_my_decks
    Deck.where(user_id: current_user.id)
      .all
      .compact
      .sort_by{|d| "#{d.klass.try(:name)} #{d.name}"}
  end
end
