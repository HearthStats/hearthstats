class MatchDeck < ActiveRecord::Base
  attr_accessible :deck_id, :match_id
  belongs_to :deck
  belongs_to :match, :dependent => :destroy

  before_save :set_unique_deck
  after_create :update_deck_user_stats

  def set_unique_deck
    if !self.deck.nil? && !self.deck.unique_deck.nil?
      self.match.unique_deck = self.deck.unique_deck
      self.match.save()
    end
  end

  def update_deck_user_stats
    #update personal stats
    self.deck.update_user_stats()
    self.deck.save()
  end
end
