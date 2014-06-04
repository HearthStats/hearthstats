class CardSet < ActiveRecord::Base
  attr_accessible :name
  
  ### ASOCIATIONS:
  
  has_many :cards
end
