class UniqueDeckCard < ActiveRecord::Base
  attr_accessible :unique_deck_id, :card_id
  belongs_to :unique_deck
  belongs_to :card
end
