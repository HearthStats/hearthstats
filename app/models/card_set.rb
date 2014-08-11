class CardSet < ActiveRecord::Base
  attr_accessible :name

  ### ASSOCIATIONS:

  has_many :cards

end
