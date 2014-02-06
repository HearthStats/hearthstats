class Match < ActiveRecord::Base
  attr_accessible :created_at, :updated_at, :user_id, :class_id, :oppclass_id, :oppname, :mode_id, :result_id, :notes
  belongs_to :arena_run
  has_one :klass

  belongs_to :deck
  has_one :rank, :through => :match_rank
  has_one :mode
  has_one :result

  belongs_to :user

end
