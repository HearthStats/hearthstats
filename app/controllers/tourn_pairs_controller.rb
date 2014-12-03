class TournPairsController < ApplicationController
  def show
    @pair = TournPair.find(params[:id])
    @tourn_match = TournMatch.new
    @tournament = Tournament.find(@pair.tournament_id)
    t_match_reports = TournMatch.where(tourn_pair_id: @pair.id)
    if !current_user.nil? && @pair.is_a_player(current_user.id)
      if !@pair.winner_id.nil?
        redirect_to @tournament, alert: 'This matchup has already been decided.' and return
      end
      @t_id = @pair.tournament_id
      @t_user = TournUser.where(tournament_id: @t_id, user_id: current_user.id).first
      @decks = TournDeck.where(tournament_id: @t_id, tourn_user_id: @t_user.id)
      @deck_names = @decks.map{|d| d.deck.name}
      @user_matches = t_match_reports.where(tourn_user_id: @t_user.id)
      @opp_matches = t_match_reports.where("tourn_user_id != ?", @t_user)
    else
      @p1_matches = t_match_reports.where(tourn_user_id: @pair.p1_id)
      @p2_matches = t_match_reports.where(tourn_user_id: @pair.p2_id)
    end
    render layout: "no_breadcrumbs"
  end

  def edit
    @pair = TournPair.find(params[:id])
    @tournament = Tournament.find(@pair.tournament_id)
    if current_user.nil? || !current_user.has_role?(:tourn_admin, @tournament)
      redirect_to @pair, alert: 'You are not the tournament admin.' and return
    end
    matches = TournMatch.where(tourn_pair_id: params[:id])
    @p1_matches = matches.where(tourn_user_id: @pair.p1_id)
    @p2_matches = matches.where(tourn_user_id: @pair.p2_id)
    render layout: "no_breadcrumbs"
  end

  def delete_match
    TournMatch.delete(params[:id])
  end

  def add_match
    @pair = TournPair.find(params[:id])
    TournMatch.create(tourn_pair_id: params[:id], tourn_user_id: params[:t_user_id], round: params[:count], result_id: 0)
    redirect_to edit_tourn_pair_path(@pair), notice: 'Added match.'
  end

  def update
    @pair = TournPair.find(params[:id])
    matches = params[:matches]
    winner_id = params[:winner_id]
    matches.keys.each do |key|
      id = key.split('_')[1].to_i
      round = matches[key]["round"].to_i
      deck = matches[key]["deck"].to_i
      result = matches[key]["result"].to_i
      TournMatch.update(id, round: round, tourn_deck_id: deck, result_id: result )
    end
    @pair.winner_id = winner_id
    @pair.save!
    redirect_to @pair, notice: 'Pair was successfully updated.' and return
  end
end