class TournamentsController < ApplicationController

  before_filter :admin_user?, only: [:new, :create]

  def new
    @tournament = Tournament.new
    @formats = Tournament.all_formats
    respond_to do |format|
      format.html  # new.html.erb
    end
  end

  def show
    @tournament = Tournament.find(params[:id])
    @format = Tournament.format_to_s(@tournament.bracket_format)
    @joined = false
    if !current_user.nil?
      user_entry = TournUser.where(user_id: current_user.id, tournament_id: params[:id])
      @joined = !user_entry.empty?
    end

    if @tournament.started?
      # @winner_id = @tournament.find_winner_id
      @pairs = TournPair.where(tournament_id: params[:id])
      @num_columns = Math.log2(@pairs.length + 1).ceil
      if @joined
        @my_lpairings = @pairs.where(p1_id: user_entry.first.id)
        @my_rpairings = @pairs.where(p2_id: user_entry.first.id)
        if @tournament.bracket_format > 0
          @my_lpairings = @my_lpairings.select {|pair| pair.undecided == -1}
          @my_rpairings = @my_rpairings.select {|pair| pair.undecided == -1}
        end
        @total_pairs = @my_lpairings.length + @my_rpairings.length
      end
    else
      if @joined
        @submitted = user_entry.first.decks_submitted?
        if !@submitted
          @user_decks = Deck.playable_decks(current_user.id)
        else
          @submitted_decks = TournDeck.where(tournament_id: params[:id], tourn_user_id: user_entry.first.id)
        end
      end
    end
  end

  def admin
    @tournament = Tournament.find(params[:id])
    if !current_user.has_role? :tourn_admin, @tournament
      redirect_to(@tournament, alert: 'You are not an admin of this tournament') and return
    end
    @players = @tournament.tourn_users
  end

  ### ACTIONS WITH NO PAGE

  def create
    params[:tournament][:creator_id] = current_user.id
    @tournament = Tournament.new(params[:tournament])
    @formats = Tournament.all_formats
    respond_to do |format|
      if @tournament.save
        current_user.add_role :tourn_admin, @tournament
        format.html  { redirect_to(@tournament,
                       notice: 'Tournament was successfully created.') }
      else
        format.html  { render action: "new" }
      end
    end
  end

  def start
    @tournament = Tournament.find(params[:id])
    if !@tournament.started
      respond_to do |format|
        if @tournament.start_tournament
          format.html { redirect_to(@tournament, notice: 'Tournament has started') }
        else
          format.html { redirect_to(@tournament, alert: 'Error in starting tournament, check messages')}
        end
      end
    end
  end

  def join
    @tournament = Tournament.find(params[:id])
    @user_decks = Deck.playable_decks(current_user.id)
    respond_to do |format|
      @code_error = (@tournament.code != params[:code])
      if !@tournament.is_private or !@code_error
        @not_full = not_full?(@tournament)
        if @not_full
          TournUser.create(user_id: current_user.id, tournament_id: params[:id])
        end
      end
      format.js
    end
  end

  def not_full?(tournament)
    max_players = tournament.num_players
    cur_player_count = TournUser.where(tournament_id: tournament.id).count
    max_players > cur_player_count
  end

  def quit
    @tournament = Tournament.find(params[:id])
    tourn_user_id = TournUser.where(user_id: current_user.id, tournament_id: params[:id]).first.id
    TournDeck.destroy_all(tournament_id: params[:id], tourn_user_id: tourn_user_id)
    TournUser.destroy(tourn_user_id)
    respond_to do |format|
      format.js
    end
  end

  def submit_deck
    tournament = Tournament.find(params[:id])
    tourn_user = TournUser.where(user_id: current_user.id, tournament_id: tournament.id).first
    deck_count = Deck.playable_decks(current_user.id).count
    (1..deck_count).each do |deck_num|
      deck_id = params["deck_#{deck_num-1}"]
      if !deck_id.nil?
        TournDeck.create(deck_id: deck_id,
                         tournament_id: params[:id],
                         tourn_user_id: tourn_user.id)
        Deck.update(deck_id, is_tourn_deck: true, is_public: false)
      end
    end

    respond_to do |format|
      format.html { redirect_to(tournament, notice: 'Decks Submitted') }
    end
  end

  def remove_player
    @player_id = params[:player_id]
    TournUser.delete(@player_id)
    respond_to do |format|
      format.js
    end
  end
end
