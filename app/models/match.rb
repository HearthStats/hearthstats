class Match < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  # Overwrite what is passed to ES

  def as_indexed_json(options={})
    response = self.as_json
    response[:klass_name] = Klass::LIST[self.klass_id]
    response[:oppclass_name] = Klass::LIST[self.oppclass_id]
    response[:result_name] = RESULTS_LIST[self.result_id]
    response[:mode_name] = MODES_LIST[self.mode_id]
    response[:rank_name] = self.rank.try(:name)
    response[:deck_id] = self.deck.try(:id)

    return response
  end

  attr_accessible :created_at, :updated_at, :user_id, :klass_id,
                  :oppclass_id, :oppname, :mode_id, :result_id, :notes, :coin, :arena_run_id

  RESULTS_LIST = {
    1 => 'Win',
    2 => 'Loss',
    3 => 'Draw'
  }

  MODES_LIST = {
    1 => 'Arena',
    2 => 'Casual',
    3 => 'Ranked',
    4 => 'Tournament',
    5 => 'Friendly'
  }

  ### ASSOCIATIONS:

  has_one :match_run
  has_one :arena_run, through: :match_run

  has_one :match_deck
  has_one :deck, through: :match_deck

  has_one :match_unique_deck
  has_one :unique_deck, through: :match_unique_deck

  has_one :match_rank
  has_one :rank, through: :match_rank

  belongs_to :match_result
  belongs_to :result, class_name: 'MatchResult', foreign_key: 'result_id'

  belongs_to :mode
  belongs_to :user, touch: true

  belongs_to :klass, class_name: 'Klass', foreign_key: 'klass_id'
  belongs_to :oppclass, class_name: 'Klass', foreign_key: 'oppclass_id'

  belongs_to :match_result, class_name: 'MatchResult', foreign_key: 'result_id'

  belongs_to :season
  belongs_to :patch

  belongs_to :tourn_match

  ### SCOPES:

  scope :wins,   where(result_id: 1)
  scope :losses, where(result_id: 2)
  scope :draws,  where(result_id: 3)

  ### VALIDATIONS:

  validates_presence_of :result_id
  validates_presence_of :mode_id
  validates_presence_of :oppclass_id
  validates_presence_of :klass_id

  ### CALLBACKS:

  before_save :set_season_patch
  after_save :update_user_stats_constructed

  ### CLASS METHODS:

  def self.winrate_by_time(matches, timezone)
    Time.zone = timezone
    time_wr = {}
    24.times.each do |time|
      time_wr[time+1] = nil
    end
    hr_group = matches.group_by {|match| Time.zone.parse(match.created_at.to_s).hour}
    hr_group.each do |hr|
      wins = hr[1].select { |match| match.result_id == 1}.count
      total = hr[1].count
      wr = wins.to_f/total
      time_wr[hr[0]] = wr*100
    end

    time_wr.sort
  end

  def self.get_klass_ranked_wr(args)
    klasses_array = args[:klasses_array]
    beginday    = args[:beginday]
    endday      = args[:endday]
    # klass_array = { 1 => "Druid", etc. }
    ranked_stats_array = Array.new
    ranked_count_array = Hash.new
    klasses_array.each do |klass|
      winrate = self.get_rank_wr_array_for_klass(klass[0], beginday, endday)
      ranked_stats_array << winrate.win_rate_array
      ranked_count_array[klass[1]] = winrate.win_counts
    end

    [ranked_stats_array, ranked_count_array]
  end

  Winrate = Struct.new(:win_rate_array, :win_counts)
  def self.get_rank_wr_array_for_klass(klass_id, beginning, endday)
    klass_wr = Array.new
    match_count = Array.new
    Rank.all.each do |rank|
      matches = rank.matches.where(klass_id: klass_id, 
                                   created_at: beginning..endday)
      id = rank.id
      if rank.id == 26
        id = 0
        klass_wr.unshift([id, self.get_win_rate(matches)])
        match_count.unshift(matches.length)
      else
        klass_wr << [id, self.get_win_rate(matches)]
        match_count << matches.length
      end
    end

    Winrate.new(klass_wr, match_count)
  end

  def self.winrate_per_day(all_matches, before_days)
    matches = all_matches
      .where("created_at >= ?", before_days.days.ago.beginning_of_day)
      .group_by_day(:created_at)
    wins = matches.where(result_id: 1).count
    tot = matches.count
    winrate = Array.new
    wins.zip(tot).map do |x, y|
      wr =  ((x[1].to_f/y[1] rescue 0)*100).round(2)
      wr = 0 if wr == Float::NAN
      winrate << [x[0].to_time.to_i*1000, wr]
    end

    winrate
  end

  def self.winrate_per_day_cumulative(all_matches, before_days)
    wins = {}
    matches = all_matches
      .select {|match| match.created_at >= before_days.days.ago.beginning_of_day}
      .group_by {|match| match.created_at.beginning_of_day}
    matches.each do |date, day_matches|
      wins[date] = day_matches.select{|match| match.result_id == 1}.count
    end
    tot = matches.map{|day| [day[0], day[1].count]}
    prev_wr = 0
    winrate = Array.new
    tot.each do |day, num_of_games|
      if wins[day] == nil
        today_wr = prev_wr
      else
        wr = ((wins[day].to_f/num_of_games rescue 0)*100).round(2)
        wr = prev_wr if wr.nan?
        if prev_wr == 0
          today_wr = wr
        else
          today_wr = (wr + prev_wr)/2
        end
        prev_wr = wr
      end
      winrate << [day.to_time.to_i*1000, today_wr]

    end

    winrate.sort_by { |date, wr| date}
  end

  def self.results_list
    RESULTS_LIST.values
  end

  def self.get_win_rate(matches, strout = false )
    tot_games = matches.count
    return "N/A" if tot_games == 0

    wins = matches.where(result_id: 1).count
    win_rate = wins.to_f / tot_games
    win_rate = (win_rate * 100).round(2)
    win_rate = win_rate.to_s + "%" if strout

    win_rate
  end

  def self.search(field, query = nil)
    # this method does not seem to be called from anywhere

    if query.nil?
      return self
    else
      where("#{field} like ?", "%#{query}%" )
    end
  end

  def self.bestuserarena(userid)
    scope  = Match.where(user_id: userid, mode_id: 1).group(:klass_id)
    played = scope.count
    wins   = scope.where(result_id: 1).count

    class_arena_rate = {}
    played.each do |klass_id, count|
      class_arena_rate[klass_id] = ((wins[klass_id].to_f / count.to_f)*100).round if count > 0
    end

    return [Klass.list.first, 0] if class_arena_rate.blank?
    max = class_arena_rate.max_by {|x,y| y}

    [ Klass::LIST[max[0]], max[1] ]
  end

  def self.to_csv
    file = "#{Rails.root}/public/#{first.mode.name}_export_#{Time.now}.csv"
    CSV.open( file, 'w' ) do |writer|
      writer << [ first.mode.name + ' Games']
      writer << [
                  'Class',
                  'Opponent Class',
                  'Result',
                  'Coin?',
                  'Created Time'
                ]
      self.find_each do |match|
        next unless match.user_id
        writer << [
                    match.klass.name,
                    match.oppclass.name,
                    match.result.name,
                    match.coin,
                    match.created_at
                  ]
      end
    end
  end

  def self.winrate_per_class(matches = Match)
    total = matches.group('matches.klass_id').count
    wins  = matches.group('matches.klass_id').where(result_id: 1).count

    winrate_per_class = Array.new(9, 0)

    total.each do |klass_id, count|
      winrate_per_class[klass_id - 1] = ((wins[klass_id].to_f / count)*100).round(2)
    end

    winrate_per_class
  end

  def self.top_winrates_with_class
    total = Match.group("klass_id").count
    wins  = Match.group("klass_id").where("result_id = ?", 1).count
    winrate_per_class = Array.new(9, 0)

    total.each do |klass_id, count|
      winrate_per_class[klass_id - 1] = [Klass::LIST[klass_id], ((wins[klass_id].to_f / count)*100).round(2)]
    end

    winrate_per_class.sort_by { |c| c[1] }.reverse
  end

  def self.matches_per_class(matches = Match)
    matches_per_class = {}
    Klass.list.each { |klass| matches_per_class[klass] = 0 }

    matches.group("matches.klass_id").count.each do |id, count|
      matches_per_class[Klass::LIST[id]] = count
    end

    matches_per_class
  end

  def self.number_to_percent(num)
    (num*100).round(2).to_s + "%"
  end

  def self.rank_class(hours_ago)
    rank_klass = {}
    matches = Match.where(mode_id: 3, appsubmit: true)
      .where{created_at >= hours_ago.hours.ago}
      .preload(:rank)
      .all
    rank_grouped = matches.group_by{|match| match.rank}
      .select{|rank| !rank.nil?}
      .sort_by{|rank| rank[0].id}
    rank_grouped.each do |rank, rank_matches|
      grouped = rank_matches.group_by{|match| match.klass_id}
      klass_count = grouped.map{|klass, klass_matches| [klass, klass_matches.count]}
        .sort_by{|klass, count| klass}
      rank_klass[rank.id] = klass_count
    end

    rank_klass
  end

  ### INSTANCE METHODS:

  def archtype_id
    deck.try(:unique_deck).try(:unique_deck_type_id)
  end

  def deck
    match_deck.try(:deck)
  end

  def rank
    match_rank.try(:rank)
  end

  def klass
    Klass.all_klasses.find{|k| k.id == klass_id }
  end

  def oppclass
    Klass.all_klasses.find{|k| k.id == oppclass_id }
  end

  def mode
    Mode.all_modes.find{|m| m.id == mode_id}
  end

  def loss?
    result_id == 0
  end

  def win?
    result_id == 1
  end

  def set_season_patch
    self.season_id ||= Season.last.try(:id)
    self.patch_id  ||= Patch.last.try(:id)
  end

  def update_user_stats_constructed
    unless deck.nil?
      deck.update_user_stats!
    end
  end

end
