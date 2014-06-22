class DeckVersion < ActiveRecord::Base
  attr_accessible :version, :notes, :deck_id, :cardstring
  
  ### ASSOCIATIONS:
  
  belongs_to :deck
  belongs_to :unique_deck

end
