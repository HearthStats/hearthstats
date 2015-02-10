class Mechanic < ActiveRecord::Base
  attr_accessible :name

  has_many :cards, through: :card_mechanic
end
