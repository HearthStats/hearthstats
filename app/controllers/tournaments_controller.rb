class TournamentsController < ApplicationController
  def new
    @tournament = Tournament.new

    respond_to do |format|
      format.html  # new.html.erb
    end
  end

  def create
    @tournament = Tournament.new(params[:tournament])
    respond_to do |format|
      if @tournament.save
        format.html  { redirect_to(@tournament,
                       notice: 'Tournament was successfully created.') }
      else
        format.html  { render action: "new" }
      end
    end
  end

  def show
    @tournament = Tournament.find(params[:id])

    if @tournament.started?
      @pairs = TournPair.where(tournament_id: params[:id])
      @num_columns = Math.log2(@pairs.length + 1).ceil
    end

    @format = Tournament.format_to_s(@tournament.bracket_format)
    user_entry = TournUser.where(user_id: current_user.id, tournament_id: params[:id])
    @joined = !user_entry.empty?
    if @joined
      @submitted = user_entry.first.decks_submitted?
      if !@submitted
        @user_decks = Deck.playable_decks(current_user.id)
      end
    end
  end

  def join
    @tournament = Tournament.find(params[:id])
    @user_decks = Deck.playable_decks(current_user.id)
    respond_to do |format|
      @code_error = (@tournament.code != params[:code])
      if !@code_error
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
