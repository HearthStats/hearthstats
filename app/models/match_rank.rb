class MatchRank < ActiveRecord::Base
  belongs_to :rank
  belongs_to :match
end
