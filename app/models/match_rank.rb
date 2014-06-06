class MatchRank < ActiveRecord::Base
  attr_accessible :rank_id, :match_id
  
  ### ASSOCIATIONS:
  
  belongs_to :rank
  belongs_to :match
  
end
