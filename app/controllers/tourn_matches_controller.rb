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
    matches_eval_list = t_matches
    round = t_matches.count + 1
    if t_deck_id.nil?
      redirect_to(@tournament, alert: "You have submitted enough matches!")
    end
    t_match = TournMatch.new(tourn_user_id: t_user_id,
                             tourn_deck_id: t_deck_id,
                             tourn_pair_id: t_pair_id,
                             result_id: params[:result_id].to_i,
                             coin: !params[:coin].to_i.zero?,
                             round: round)
    respond_to do |format|
      if t_match.save
        opp_t_matches = TournMatch.where(tourn_pair_id: t_pair_id).where("tourn_user_id != ?", t_user_id)
        opp_cur_match = opp_t_matches.where(round: round).first
        if !opp_cur_match.nil?
          conflict = resolve_match(t_match, opp_cur_match, params[:t_id])

          matches_to_win = (@tournament.best_of.to_i / 2.0).ceil
          if opp_t_matches.count > t_matches.count
            matches_eval_list = opp_t_matches
          end

          if t_matches.count >= matches_to_win
            winner_id = determine_winner(matches_eval_list, matches_to_win, opp_cur_match.tourn_user_id)
            if winner_id != 0
              TournPair.update(t_pair_id, winner_id: winner_id)
              if @tournament.bracket_format == 1
                advance_winner(winner_id, t_pair_id)
              end
            end
          end
        end

        if conflict
          format.html { redirect_to(request.referrer, notice: "Your report conflicts with your opponent's, tournament admin has been notified") }
        else
          format.html { redirect_to(request.referrer, notice: 'Match submitted') }
        end
      else
        format.html { render action: "new" }
      end
    end
  end

end
