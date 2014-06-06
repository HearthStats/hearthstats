class MatchUniqueDeck < ActiveRecord::Base
  attr_accessible :unique_deck_id, :match_id
  
  ### ASSOCIATIONS:
  
  belongs_to :unique_deck
  belongs_to :match
  
end
