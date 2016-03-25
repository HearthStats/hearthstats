class ReportGenerator
  def initialize
  end

  def full_report(begin_date, end_date)
    @matches = Match.where(created_at: begin_date.beginning_of_day..end_date.end_of_day)
      .preload(:match_rank)
    p "#{@matches.count} matches retrieved"
  end

  def winrate_by_rank
    ranked_wr = {}
    ranked_matches = @matches
      .select {|match| match.mode_id == 3 && match.appsumbit == true}
    klass_grouped_matches = ranked_matches.group_by(&:klass_id)
    klass_grouped_matches.each do |klass_id, klass_matches|
      ranked_wr = {}
      rank_grouped_matches = klass_matches.group_by(&:match_rank)
      rank_grouped_matches.each do |rank, rank_matches|
        wins = rank_matches.select {|match| match.result_id == 1}.count
        ranked_wr[rank.rank_id] = wins.to_f / rank_matches.count
      end
      ranked_wr[klass_id] = ranked_wr
    end

    ranked_wr
  end

  def winrate_matrix(mode_id)
    winrate_matrix = {}
    mode_matches = @matches
      .select {|match| match.mode_id == mode_id}
    klass_grouped_matches = mode_matches.group_by(&:klass_id)
    klass_grouped_matches.each do |klass_id, klass_matches|
      classvclass_wr = {}
      oppclass_grouped_matches = klass_matches.group_by(&:oppclass_id)
      oppclass_grouped_matches.each do |oppclass_id, opp_matches|
        wins = opp_matches.select {|match| match.result_id == 1}.count
        classvclass_wr[oppclass_id] = wins.to_f / opp_matches.count
      end
      winrate_matrix[klass_id] = classvclass_wr
    end

    winrate_matrix
  end

  def klass_winrates(mode_id)
    klass_winrates = {}
    mode_matches = @matches
      .select {|match| match.mode_id == mode_id}
    klass_grouped_matches = mode_matches.group_by(&:klass_id)
    klass_grouped_matches.each do |klass_id, klass_matches|
      wins = klass_matches.select {|match| match.result_id == 1}
      klass_winrates[klass_id] = wins.to_f / klass_matches.count
    end
  end
end
