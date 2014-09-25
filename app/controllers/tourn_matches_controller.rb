class TournMatchesController < ApplicationController

  def new
    @tourn_match = TournMatch.new
    @t_id = params[:t_id]
    @t_pair_id = params[:pair_id]
    @t_user_id = TournUser.where(tournament_id: @t_id, user_id: current_user.id).first.id
    pair = TournPair.find(@t_pair_id)
    if params[:pos] == 0
      @opp_name = pair.p2_name
      @opp = TournUser.find(pair.p2_id)
    else
      @opp_name = pair.p1_name
      @opp = TournUser.find(pair.p1_id)
    end
    @decks = TournDeck.where(tournament_id: @t_id, tourn_user_id: @t_user_id)
    @deck_names = @decks.map{|d| d.deck.name}
    @t_match_reports = TournMatch.where(tourn_pair_id: @t_pair_id)
  end

  def create
    t_deck_id = params[params[:deckname]]
    t_user_id = params[:t_user_id]
    t_pair_id = params[:t_pair_id]
    t_matches = TournMatch.where(tourn_pair_id: t_pair_id,
                                 tourn_user_id: t_user_id)
    matches_eval_list = t_matches
    round = t_matches.count + 1
    t_match = TournMatch.new(tourn_user_id: t_user_id,
                             tourn_deck_id: t_deck_id,
                             tourn_pair_id: t_pair_id,
                             result_id: params[:result_id].to_i,
                             coin: !params[:coin].to_i.zero?,
                             round: round)
    @tournament = Tournament.find(params[:t_id])
    respond_to do |format|
      if t_match.save
        format.html { redirect_to(@tournament, notice: 'Match submitted') }
        opp_t_matches = TournMatch.where(tourn_pair_id: t_pair_id).where("tourn_user_id != ?", t_user_id)
        opp_cur_match = opp_t_matches.where(round: round)
        if opp_cur_match.count > 0
          resolve_match(t_match, opp_t_match, params[:t_id])
        end

        matches_to_win = (@tournament.best_of / 2).ceil
        if opp_t_matches.count > t_matches.count
          matches_eval_list = opp_t_matches
        end

        if t_matches.count >= matches_to_win
          winner_id = determine_winner(matches_eval_list, matches_to_win, opp_cur_match.tourn_user_id)
          if winner_id != 0
            TournPair.update(t_pair_id, winner_id: winner_id)
          end
        end
      else
        format.html { render action: "new" }
      end
    end
  end

  def resolve_match(t_match, opp_t_match, t_id)
    id_sum = t_match.result_id.to_i + opp_t_match.result_id.to_i
    # sum of 3 means a win and a loss was picked
    # a sum of 6 means both players picked draw
    if id_sum != 3 and id_sum != 6
      flash[:notice] = "Your report conflicts with your opponent's, tournament admin has been notified"
      tourny = Tournament.find(t_id)
      admins = User.with_role(:tourn_admin, tourny)
      user = TournUser.find(t_match.tourn_user_id).user
      opp = TournUser.find(opp_name.tourn_user_id).user
      admins.each do |admin|
        admin.notify( "Conflict notice",
                      "Conflict on the match " + t_match.round + " report " +
                      "between " + user.profile.name + "(" + user.email + ")" +
                      " and " + opp.profile.name + "(" + opp.email + ")" )
      end
    end
  end

  def determine_winner(match_list, matches_to_win, other_user_id)
    match_list.each do |match|
      cur_user_wins = 0
      other_user_wins = 0
      if match.result_id == 0
        cur_user_wins += 1
        if cur_user_wins == matches_to_win
          return match.tourn_user_id
        end
      else
        other_user_wins += 1
        if other_user_wins == matches_to_win
          return other_user_id
        end
      end
    end
    return 0
  end

end
