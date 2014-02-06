class MatchDeck < ActiveRecord::Base
  attr_accessible :deck_id, :match_id
  belongs_to :decks
  belongs_to :matchs
end
