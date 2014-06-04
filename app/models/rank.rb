class Rank < ActiveRecord::Base
  attr_accessible :name
  has_many :matches, through: :match_ranks
  has_many :match_ranks
end
