class MatchRank < ActiveRecord::Base
  has_many :ranks
  belongs_to :match
end
