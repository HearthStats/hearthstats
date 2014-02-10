class Match < ActiveRecord::Base
  attr_accessible :created_at, :updated_at, :user_id, :klass_id, :oppclass_id, :oppname, :mode_id, :result_id, :notes, :coin, :arena_run_id

  has_one :match_run
  has_one :arena_run, :through => :match_run

  has_one :match_deck
  has_one :deck, :through => :match_deck

  has_one :match_rank
  has_one :rank, :through => :match_rank
  belongs_to :mode
  belongs_to :user

  belongs_to :klass, :class_name => 'Klass', :foreign_key => 'klass_id'
  belongs_to :oppclass, :class_name => 'Klass', :foreign_key => 'oppclass_id'

  belongs_to :match_result, :class_name => 'MatchResult', :foreign_key => 'result_id'

  belongs_to :seaon
  belongs_to :patch
end
