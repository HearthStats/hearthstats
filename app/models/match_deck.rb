class MatchDeck < ActiveRecord::Base
  attr_accessible :deck_id, :match_id
  belongs_to :deck
  belongs_to :match
  
  before_save :set_unique_deck
  
  def set_unique_deck
    if !self.deck.nil? && !self.deck.unique_deck.nil?
      self.match.unique_deck = self.deck.unique_deck
      self.match.save()
    end
  end
end
