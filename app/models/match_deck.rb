class MatchDeck < ActiveRecord::Base
  attr_accessible :deck_id, :match_id
  belongs_to :deck
  belongs_to :match
  
  before_save :set_unique_deck_and_update_stats
  
  def set_unique_deck_and_update_stats
    if !self.deck.nil? && !self.deck.unique_deck.nil?
      self.match.unique_deck = self.deck.unique_deck
      self.match.save()
    end
    
    #update personal stats
    self.deck.user_num_matches = self.deck.matches.count
    self.deck.user_num_wins = self.deck.matches.where(:result_id => 1).count
    self.deck.user_num_losses = self.deck.matches.where(:result_id => 2).count
    self.deck.user_winrate = self.deck.user_num_matches > 0 ? self.deck.user_num_wins/ self.deck.user_num_matches : 0
  end
end
