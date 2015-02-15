class MatchDeck < ActiveRecord::Base
  attr_accessible :deck_id, :match_id, :deck_version_id

  ### ASSOCIATIONS:

  belongs_to :deck
  belongs_to :match, dependent: :destroy

  ### CALLBACKS:

  # before_save :set_unique_deck_and_version

  ### INSTANCE METHODS:

  # I do not see the point of this method, so it is removed for now
  # def set_unique_deck_and_version
  #   if !self.deck.nil? && !self.deck.unique_deck.nil?
  #     self.match.unique_deck = self.deck.unique_deck
  #     self.match.save
  #   end
  # end
end
