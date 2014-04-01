class UniqueDeck < ActiveRecord::Base
  attr_accessible :cardstring, :name, :user_id, :num_matches, :winrate, :num_users
  has_many :decks
  has_many :deck_versions

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
    matches = self.decks.flat_map {|m| m.matches}

    self.num_minions = self.cards.where(:type_id => 1).count
    self.num_spells = self.cards.where(:type_id => 2).count
    self.num_weapons = self.cards.where(:type_id => 3).count

    matches = self.matches.where('created_at >= ?', 30.days.ago)

    self.num_users = self.decks.where(:klass_id => self.klass_id).count
    self.num_matches = matches.count
    self.num_wins = matches.select{ |m| m.result_id == 1 }.count
    self.num_losses = matches.select{ |m| m.result_id == 2 }.count
    self.winrate = self.num_matches > 0 ? (self.num_wins.to_f / self.num_matches.to_f * 100) : 0

  end
end
