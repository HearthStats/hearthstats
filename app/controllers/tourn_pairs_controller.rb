class TournPairsController < ApplicationController
  def show
    tourn_pair = TournPair.find(params[:id])
    if ![ tourn_pair.p1.id, tourn_pair.p2.id ].include? current_user.id
      redirect_to root_path, alert: "You are not part of that match" and return
    end
    @t_id = tourn_pair.tournament.id
    @tourn_match = TournMatch.new
    @t_user_id = TournUser.where(tournament_id: @t_id, user_id: current_user.id).first.id
    @pair = TournPair.find(tourn_pair.id)
    if params[:pos] == 0
      @opp_name = @pair.p2_name
      @opp = TournUser.find(@pair.p2_id)
    else
      @opp_name = @pair.p1_name
      @opp = TournUser.find(@pair.p1_id)
    end
    @decks = TournDeck.where(tournament_id: @t_id, tourn_user_id: @t_user_id)
    @deck_names = @decks.map{|d| d.deck.name}
    @t_match_reports = TournMatch.where(tourn_pair_id: tourn_pair.id)
    @t_pair_id = tourn_pair.id
    render layout: "no_breadcrumbs"
  end
end