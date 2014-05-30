class Rank < ActiveRecord::Base
  attr_accessible :name
  has_many :matches, through: :match_rank
end
