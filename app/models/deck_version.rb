class DeckVersion < ActiveRecord::Base
  attr_accessible :name, :notes, :deck_id, :unique_deck_id
  belongs_to :deck

end
