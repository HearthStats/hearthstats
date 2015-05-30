class TournPair < ActiveRecord::Base
  attr_accessible :tournament_id, :p1_id, :p2_id, :pos, :roundof, :winner_id,
                  :winners, :undecided

  belongs_to :tournament
  has_many :tourn_matches

  ## note about undecided:
  ## -1: no player undecided
  ## 0: left player undecided
  ## 1: right player undecided
  ## 2: both players undecided

  def p1
    TournUser.find(self.p1_id).user
  end

  def p2
    TournUser.find(self.p2_id).user
  end

  def p1_name
    TournUser.find(self.p1_id).user.name
  end

  def p2_name
    TournUser.find(self.p2_id).user.name
  end

  def get_p1_score
    TournMatch.where(tourn_pair_id: id, result_id: 0, tourn_user_id: self.p1_id).count + TournMatch.where(tourn_pair_id: id, result_id: 2, tourn_user_id: self.p1_id).count * 0.5
  end

  def get_p2_score
    TournMatch.where(tourn_pair_id: id, result_id: 0, tourn_user_id: self.p2_id).count + TournMatch.where(tourn_pair_id: id, result_id: 2, tourn_user_id: self.p2_id).count * 0.5
  end

  def conflict?
    matches = TournMatch.where(tourn_pair_id: id)
    (matches.count / 2).times do |i|
      pair = matches.select{|match| match.round == (i+1)}
      if pair.count != 2
        return false
      end
      total_result = pair[0].result_id + pair[1].result_id
      if total_result != 1 && total_result != 4
        return true
      end
    end
    false
  end

  def is_a_player(user_id)
    p1 = TournUser.find(p1_id)
    p2 = TournUser.find(p2_id)
    result = false
    if user_id == p1.user_id || user_id == p2.user_id
      result = true
    end
    result
  end

  def confirm_match(t_matches)
    tournament = Tournament.find(self.tournament_id)
    matches_to_win = (tournament.best_of.to_i / 2.0).ceil
    opp_t_matches = TournMatch.where(tourn_pair_id: id).where("tourn_user_id != ?", t_matches.first.tourn_user_id)
    round = t_matches.count
    opp_cur_match = opp_t_matches.where(round: round).first
    matches_eval_list = t_matches
    p opp_cur_match
    if !opp_cur_match.nil?
      conflict = resolve_match(t_matches.last, opp_cur_match)
      if opp_t_matches.count > t_matches.count
        matches_eval_list = opp_t_matches
      end
      p "determine winner"
      winner_id = determine_winner(matches_eval_list, matches_to_win, opp_cur_match.tourn_user_id)
      if winner_id != 0
        TournPair.update(id, winner_id: winner_id)
        if tournament.bracket_format == 1 && self.roundof != 2
          advance_winner(winner_id)
        end
      end
    end
  end

  def resolve_match(t_match, opp_t_match)
    id_sum = t_match.result_id.to_i + opp_t_match.result_id.to_i
    # sum of 3 means a win and a loss was picked
    # a sum of 6 means both players picked draw
    if id_sum != 1 and id_sum != 4
      tourny = Tournament.find(self.tournament_id)
      admins = User.with_role(:tourn_admin, tourny)
      user = TournUser.find(t_match.tourn_user_id).user
      opp = TournUser.find(opp_t_match.tourn_user_id).user
      return true
    end
    false
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

  def get_parent_pair
    parent_pair = TournPair.where(tournament_id: @tournament.id, p1_id: id).first
    if parent_pair.nil?
      parent_pair = TournPair.where(tournament_id: @tournament.id, p2_id: id).first
    end
    parent_pair
  end

  def advance_winner(winner_id)
    parent_pair = get_parent_pair
    if parent_pair.p1_id == id
      TournPair.update(parent_pair.id, p1_id: winner_id)
    else
      TournPair.update(parent_pair.id, p2_id: winner_id)
    end

    if parent_pair.undecided < 2 # if one player is already decided
      TournPair.update(parent_pair.id, undecided: -1)  # then both players are decided
    end
  end

  def users
    [ TournUser.find(p1_id).user, TournUser.find(p2_id).user]
  end
end
