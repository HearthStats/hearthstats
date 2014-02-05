class MatchResult < ActiveRecord::Base
  attr_accessible :result
  belongs_to :match
end
