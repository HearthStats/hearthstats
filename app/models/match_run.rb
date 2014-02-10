class MatchRun < ActiveRecord::Base
  attr_accessible :arena_run_id, :match_id
  belongs_to :match
  belongs_to :arena_run
end
