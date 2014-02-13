class UniqueDeck < ActiveRecord::Base
  attr_accessible :cardstring, :name, :user_id, :num_matches
  has_many :deck
  
  has_many :cards, :through => :unique_deck_card
  has_many :unique_deck_card
  
  has_many :matches, :through => :match_unique_deck
  has_many :match_unique_deck
  
  before_save :update_stats
  
  def update_stats
    
    #remove existing cards
    self.unique_deck_card.destroy_all()
    
    #update cards from cardstring
    cards = self.cardstring.split(',')
    cards.each do |cardData|
      chunks = cardData.split('_')
      (1..chunks[1].to_f).each do |i|
        card = Card.find(chunks[0])
        self.cards << card
      end
    end

    self.num_minions = self.cards.where(:type_id => 1).count
    self.num_spells = self.cards.where(:type_id => 2).count
    self.num_weapons = self.cards.where(:type_id => 3).count
    
    self.num_matches = self.matches.count
    self.num_wins = self.matches.where(:result_id => 1).count
    self.num_losses = self.matches.where(:result_id => 2).count
    
  end
end
