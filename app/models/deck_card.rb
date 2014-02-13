class DeckCard < ActiveRecord::Base
  attr_accessible :deck_id, :card_id
  belongs_to :deck
  belongs_to :card
end
