class TournMatchesController < ApplicationController

  def new
    @tourn_match = TournMatch.new
    @t_id = params[:t_id]
    @t_pair_id = params[:pair_id]
    pair = TournPair.find(@t_pair_id)
    if !pair.winner_id.nil?
      redirect_to Tournament.find(@t_id) and return
    end
    @t_user_id = TournUser.where(tournament_id: @t_id, user_id: current_user.id).first.id
    if params[:pos] == 0
      @opp_name = @pair.p2_name
      @opp = TournUser.find(@pair.p2_id)
    else
      @opp_name = @pair.p1_name
      @opp = TournUser.find(@pair.p1_id)
    end
    @decks = TournDeck.where(tournament_id: @t_id, tourn_user_id: @t_user_id)
    @deck_names = @decks.map{|d| d.deck.name}
    @t_match_reports = TournMatch.where(tourn_pair_id: @t_pair_id)
    render layout: "no_breadcrumbs"
  end

  def create
    t_deck_id = params[params[:deckname]]
    t_user_id = params[:t_user_id]
    t_pair_id = params[:t_pair_id]
    t_matches = TournMatch.where(tourn_pair_id: t_pair_id,
                                 tourn_user_id: t_user_id)
    @tournament = Tournament.find(params[:t_id])
    round = t_matches.count + 1
    if round > @tournament.best_of
      redirect_to(@tournament, alert: "You have submitted enough matches!") and return
    end
    t_match = TournMatch.new(tourn_user_id: t_user_id,
                             tourn_deck_id: t_deck_id,
                             tourn_pair_id: t_pair_id,
                             result_id: params[:result_id].to_i,
                             coin: !params[:coin].to_i.zero?,
                             round: round)
    respond_to do |format|
      if t_match.save
        t_pair = TournPair.find(t_pair_id)
        conflict = t_pair.confirm_match(t_matches)
        if conflict
          format.html { redirect_to(request.referrer, notice: "Your report conflicts with your opponent's, tournament admin has been notified") and return }
        else
          format.html { redirect_to(request.referrer, notice: 'Match submitted') and return }
        end
      else
        format.html { render action: "new" }
      end
    end
  end

end
