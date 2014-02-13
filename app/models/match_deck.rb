class MatchDeck < ActiveRecord::Base
  attr_accessible :deck_id, :match_id
  belongs_to :deck
  belongs_to :match
end
