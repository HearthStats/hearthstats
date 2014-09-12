class TournamentsController < ApplicationController

### PAGES
  def new
    @tournament = Tournament.new
    @formats = Tournament.all_formats
    respond_to do |format|
      format.html  # new.html.erb
    end
  end

  def match
    pair = TournPair.find(params[:pair_id])
    @tournament = Tournament.find(params[:id])
    p1 = TournUser.find(pair.p1_id)
    p2 = TournUser.find(pair.p2_id)
    @p1_decks = TournDeck.where(tourn_user_id: p1.id)
    @p2_decks = TournDeck.where(tourn_user_id: p2.id)
    raise
    ## deck_submission
    ## screenshot
    respond_to do |format|
      format.html
    end
  end

  def show
    @tournament = Tournament.find(params[:id])
    @format = Tournament.format_to_s(@tournament.bracket_format)
    user_entry = TournUser.where(user_id: current_user.id, tournament_id: params[:id])
    @joined = !user_entry.empty?

    if @tournament.started?
      @pairs = TournPair.where(tournament_id: params[:id])
      @num_columns = Math.log2(@pairs.length + 1).ceil
      if @joined
        @my_lpairings = @pairs.where(p1_id: user_entry.first.id)
        @my_rpairings = @pairs.where(p2_id: user_entry.first.id)
        @total_pairs = @my_lpairings.length + @my_rpairings.length
      end
    else
      if @joined
        @submitted = user_entry.first.decks_submitted?
        if !@submitted
          @user_decks = Deck.playable_decks(current_user.id)
        end
      end
    end
  end

  def admin
    @tournament = Tournament.find(params[:id])
    if !current_user.has_role? :tourn_admin, @tournament
      redirect_to(@tournament, alert: 'You are not an admin of this tournament')
    end
    @players = @tournament.users
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
    @tournament.started = true
    @tournament.start_tournament
    respond_to do |format|
      if @tournament.save
        format.html { redirect_to(@tournament, notice: 'Tournament has started') }
      else
        format.html { render action: "admin"}
      end
    end
  end

  def join
    @tournament = Tournament.find(params[:id])
    @user_decks = Deck.playable_decks(current_user.id)
    respond_to do |format|
      @code_error = (@tournament.code != params[:code])
      if !@tournament.is_private or !@code_error
          TournUser.create(user_id: current_user.id, tournament_id: params[:id])
      end
      format.js
    end
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
    chosen_deck_ids = []
    (0..tournament.num_decks).each do |deck_num|
      deck_id = params["deck_#{deck_num}"]
      if !deck_id.nil?
        TournDeck.create(deck_id: deck_id,
                         tournament_id: params[:id],
                         tourn_user_id: tourn_user.id)
        Deck.update(deck_id, is_tour_deck: true)
      end
    end

    respond_to do |format|
      format.js
    end
  end
end
