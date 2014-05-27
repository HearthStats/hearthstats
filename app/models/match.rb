class Match < ActiveRecord::Base
  attr_accessible :created_at, :updated_at, :user_id, :klass_id, 
                  :oppclass_id, :oppname, :mode_id, :result_id, :notes, :coin, :arena_run_id
  
  ### SCOPES:
  
  scope :wins,   where(result_id: 1)
  scope :losses, where(result_id: 2)
  scope :draws,  where(result_id: 3)
  
  ### ASSOCIATIONS:
  
  has_one :match_run
  has_one :arena_run, :through => :match_run
  
  has_one :match_deck
  has_one :deck, :through => :match_deck, :dependent => :destroy
  
  has_one :match_unique_deck
  has_one :unique_deck, :through => :match_unique_deck
  
  has_one :match_rank
  has_one :rank, :through => :match_rank
  
  belongs_to :match_result
  belongs_to :result, :class_name => 'MatchResult', :foreign_key => 'result_id'
  
  belongs_to :mode
  belongs_to :user
  
  belongs_to :klass, :class_name => 'Klass', :foreign_key => 'klass_id'
  belongs_to :oppclass, :class_name => 'Klass', :foreign_key => 'oppclass_id'
  
  belongs_to :match_result, :class_name => 'MatchResult', :foreign_key => 'result_id'
  
  belongs_to :season
  belongs_to :patch
  
  ### VALIDATIONS:
  
  validates_presence_of :result_id
  validates_presence_of :mode_id
  validates_presence_of :oppclass_id
  validates_presence_of :klass_id
  
  ### CALLBACKS:
  
  before_save :set_season_patch
  after_save :update_user_stats_constructed
  
  ### CLASS METHODS:
  
  def self.search(field, query = nil)
    if query.nil?
      return self
    else
      where("#{field} like ?", "%#{query}%" )
    end
  end
  
  def self.bestuserarena(userid)
    class_arena_rate = Hash.new
    (1..Klass.count).each_with_index do |c,i|
      totalwins = 0
      totalgames = 0
      totalwins = Match.where(:klass_id => c, :result_id => 1, :user_id => userid, mode_id: 1 ).count
      totalgames = Match.where(:klass_id => c, :user_id => userid, mode_id: 1 ).count
      if totalgames == 0
        class_arena_rate[Klass.find(c).name] = 0
      else
        class_arena_rate[Klass.find(c).name] = ((totalwins.to_f / totalgames)*100).round
      end
    end
    arena_class = class_arena_rate.max_by {|x,y| y}
    
    arena_class
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
  
  ### INSTANCE METHODS:
  
  def set_season_patch
    self.season_id ||= Season.last.try(:id)
    self.patch_id  ||= Patch.last.try(:id)
  end
  
  def update_user_stats_constructed
    unless self.deck.nil?
      self.deck.update_user_stats
      self.deck.save!
    end
  end
  
end
