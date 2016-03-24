class ReportGenerator
  def initialize
  end

  def full_report(begin_date, end_date)
    @matches = Match.where(created_at: begin_date.beginning_of_day..end_date.end_of_day)
      .includes(:match_rank)
    logger.info "#{@matches.count} matches retrieved"
  end

  def winrate_by_rank(matches)
    ranked_matches = matches
      .select {|match| match.mode_id == 3 && match.appsumbit == true}
    klass_grouped_matches = ranked_matches.group_by(&:klass_id)
    klass_grouped_matches.each do |klass_id, klass_matches|
      # match.match_rank
      rank_grouped_matches = klass_matches.group_by(&:match_rank)
      # structure: {match_rank_obj => [matches], etc}
      # Reject nil rank incase of online entry
    end
  end
end
