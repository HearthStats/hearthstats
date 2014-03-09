class Match < ActiveRecord::Base
  attr_accessible :created_at, :updated_at, :user_id, :klass_id, :oppclass_id, :oppname, :mode_id, :result_id, :notes, :coin, :arena_run_id

  scope :wins, ( where(result_id: 1) )
  scope :losses, ( where(result_id: 2) )
  scope :draws, ( where(result_id: 3) )


  has_one :match_run
  has_one :arena_run, :through => :match_run

  has_one :match_deck
  has_one :deck, :through => :match_deck, :dependent => :destroy

  has_one :match_unique_deck
  has_one :unique_deck, :through => :match_unique_deck

  has_one :match_rank
  has_one :rank, :through => :match_rank
  belongs_to :mode
  belongs_to :user

  belongs_to :klass, :class_name => 'Klass', :foreign_key => 'klass_id'
  belongs_to :oppclass, :class_name => 'Klass', :foreign_key => 'oppclass_id'

  belongs_to :match_result, :class_name => 'MatchResult', :foreign_key => 'result_id'

  belongs_to :season
  belongs_to :patch

  before_save :set_season_patch

  def set_season_patch
    self.season_id ||= Season.last.id
    self.patch_id ||= Patch.last.id
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
 end
