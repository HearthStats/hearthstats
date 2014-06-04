class Rank < ActiveRecord::Base
  attr_accessible :name
  
  ### ASSOCIATIONS:
  
  has_many :matches, through: :match_rank
end
