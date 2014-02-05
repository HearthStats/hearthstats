class Rank < ActiveRecord::Base
  attr_accessible :name
  belongs_to :match_ranks
end
