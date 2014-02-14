class MatchRank < ActiveRecord::Base
  attr_accessible :rank_id, :match_id
  belongs_to :rank
  belongs_to :match
end
