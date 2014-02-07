class MatchRun < ActiveRecord::Base
  belongs_to :match
  belongs_to :arena_run
end
