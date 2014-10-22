class GraphGenerator

  attr_reader :matches
  def initialize(matches)
    @matches = matches
  end
  def rank_wr
    ranked_wr_args = defaults
    ranked_wr_count = Match.get_klass_ranked_wr(ranked_wr_args)
    @ranked_winrates = ranked_wr_count[0]
    gon.ranked_wr_counts = ranked_wr_count[1]
  end

  def defaults
    {
      :klasses_array => Klass::LIST,
      :beginday => Season.last.begin,
      :endday => Season.last.end
    }
  end
end
