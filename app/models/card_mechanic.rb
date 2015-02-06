class CardMechanic < ActiveRecord::Base
  attr_accessible :card_id, :mechanic_id

  belongs_to :card
  belongs_to :mechanic
end
