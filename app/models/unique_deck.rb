class UniqueDeck < ActiveRecord::Base
  attr_accessible :cardstring, :name, :user_id, :num_matches, :winrate, :num_users
  has_many :decks
  has_many :deck_versions

  has_many :cards, :through => :unique_deck_card
  has_many :unique_deck_card

  has_many :matches, :through => :match_unique_deck
  has_many :match_unique_deck

  before_save :update_stats

  is_impressionable

  acts_as_taggable

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
    decks = self.decks

    self.num_minions = self.cards.where(:type_id => 1).count
    self.num_spells = self.cards.where(:type_id => 2).count
    self.num_weapons = self.cards.where(:type_id => 3).count
    self.num_users = self.decks.where(:klass_id => self.klass_id).count
    self.num_matches = decks.map(&:user_num_matches).compact.inject(:+)
    self.num_wins = decks.map(&:user_num_wins).compact.inject(:+)
    self.num_losses = decks.map(&:user_num_losses).compact.inject(:+)
    self.winrate = !self.num_matches.blank? ? (self.num_wins.to_f / self.num_matches.to_f * 100) : 0

  end
end
