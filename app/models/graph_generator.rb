class GraphGenerator

  attr_reader :matches, :user_klass_ids, :opp_klass_ids

  TIME_SEGMENTS = {}
  (0..5).each { |time| TIME_SEGMENTS[time] = "latenight" }
  (6..11).each { |time| TIME_SEGMENTS[time] = "morning" }
  (12..14).each { |time| TIME_SEGMENTS[time] = "lunch" }
  (15..18).each { |time| TIME_SEGMENTS[time] = "afternoon" }
  (19..24).each { |time| TIME_SEGMENTS[time] = "night" }

  def initialize(matches, user_klass_ids, opp_klass_ids)
    @matches = matches || Match.where("created_at >= ?", 1.week.ago)
    @user_klass_ids = user_klass_ids || Klass.all.pluck(:id)
    @opp_klass_ids = opp_klass_ids || Klass.all.pluck(:id)
  end

  # KLASS

  def day_wrs
    day_wrs = Hash.new
    user_klass_ids.each do |klass|
      _matches = @matches.select { |match| match.klass_id == klass }
      day_wr_klass = []
      _matches.group_by {|m| m.created_at.beginning_of_day }.each do |day|
        day_wr_klass << [ day[0].to_i * 1000,calculate_winrate(day[1]).round(2) ]
      end
      day_wrs[klass] =  day_wr_klass.sort_by { |q| q[0] }
    end

    day_wrs
  end

  def time_wrs
    time_wrs = {
      "latenight" => [],
      "morning"   => [],
      "lunch"     => [],
      "afternoon" => [],
      "night"     => []
    }
    time_matches = {
      "latenight" => [],
      "morning"   => [],
      "lunch"     => [],
      "afternoon" => [],
      "night"     => []
    }
    @matches.each do |match|
      time_matches[TIME_SEGMENTS[match.created_at.hour]] << match
    end

    time_matches.each do |time, matches|
      time_wrs[time] << [matches.count, calculate_winrate(matches)]
    end

    time_wrs
  end

  # KLASS & OPPKLASS

  def klass_wrs
    klass_wrs = Hash.new
    @user_klass_ids.each do |klass|
      @opp_klass_ids.each do |opp_klass|
        _matches = @matches.select { |match| match.klass_id == klass && 
                                     match.oppclass_id == opp_klass }
        klass_wrs[klass] = {} if klass_wrs[klass].nil?
        klass_wrs[klass][opp_klass] = calculate_winrate(_matches)
      end
    end

    klass_wrs
  end

  # WR by Rank/Class

  def rank_wr
    rank_wrs = Hash.new

    grouped = @matches.where(appsubmit: true).preload(:rank)
      .group_by { |match| match.rank }
      .find_all { |rank| !rank[0].nil? }
      .sort_by { |rank| rank[0].id }
  end

  def defaults
    {
      :klasses_array => Klass::LIST,
      :beginday => Season.last.begin,
      :endday => Season.last.end
    }
  end

  private

  def calculate_winrate(matches)
    return 0 if matches.size.zero?
    wins = matches.select{|m| m.win?}.size
    wins.to_f / matches.size * 100
  end
end
