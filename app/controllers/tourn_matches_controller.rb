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
          format.html { redirect_to(@tournament, notice: "Your report conflicts with your opponent's, tournament admin has been notified") }
        else
          format.html { redirect_to(@tournament, notice: 'Match submitted') }
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
    if id_sum != 1 and id_sum != 4
      tourny = Tournament.find(t_id)
      admins = User.with_role(:tourn_admin, tourny)
      user = TournUser.find(t_match.tourn_user_id).user
      opp = TournUser.find(opp_t_match.tourn_user_id).user
      admins.each do |admin|
        admin.notify( "Conflict notice",
                      "Conflict on the match " + t_match.round.to_s + " report " +
                      "between " + user.profile.name + "(" + user.email + ")" +
                      " and " + opp.profile.name + "(" + opp.email + ")" )
      end
      return true
    end
    return false
  end

  def determine_winner(match_list, matches_to_win, other_user_id)
    cur_user_wins = 0
    other_user_wins = 0
    match_list.each do |match|
      if match.result_id.to_i == 0
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

  def advance_winner(winner_id, cur_pair_id)
    next_t_pair = TournPair.where(tournament_id: @tournament.id, p1_id: cur_pair_id).first
    if next_t_pair.nil?
      next_t_pair = TournPair.where(tournament_id: @tournament.id, p2_id: cur_pair_id).first
      TournPair.update(next_t_pair.id, p2_id: winner_id)
    else
      TournPair.update(next_t_pair.id, p1_id: winner_id)
    end

    if next_t_pair.undecided < 2 # if one player is already decided
      TournPair.update(next_t_pair.id, undecided: -1)  # then both players are decided
    end

    if next_t_pair.nil?
      raise
    end
  end
end
