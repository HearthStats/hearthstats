class Match < ActiveRecord::Base
  attr_accessible :created_at, :updated_at, :user_id, :klass_id,
                  :oppclass_id, :oppname, :mode_id, :result_id, :notes, :coin, :arena_run_id
  
  RESULTS_LIST = {
    1 => 'Victory',
    2 => 'Defeat',
    3 => 'Draw'
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
  belongs_to :user
  
  belongs_to :klass, class_name: 'Klass', foreign_key: 'klass_id'
  belongs_to :oppclass, class_name: 'Klass', foreign_key: 'oppclass_id'
  
  belongs_to :match_result, class_name: 'MatchResult', foreign_key: 'result_id'
  
  belongs_to :season
  belongs_to :patch
  
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
  
  def self.results_list
    RESULTS_LIST.values
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
  
  def self.matches_per_class(matches = Match)
    matches_per_class = {}
    Klass.list.each { |klass| matches_per_class[klass] = 0 }
    
    matches.group("matches.klass_id").count.each do |id, count|
      matches_per_class[Klass::LIST[id]] = count
    end

    matches_per_class
  end
  
  ### INSTANCE METHODS:
  
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
