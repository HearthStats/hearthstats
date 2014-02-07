class MatchResult < ActiveRecord::Base
  attr_accessible :result
  has_many :match
end
