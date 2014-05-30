class UniqueDeck < ActiveRecord::Base
  attr_accessible :cardstring, :name, :user_id, :num_matches, :winrate, :num_users, :klass_id

  is_impressionable

  acts_as_taggable

  ### ASSOCIATIONS:

  has_many :decks
  has_many :deck_versions
  
  has_many :cards, through: :unique_deck_card
  has_many :unique_deck_card
  
  has_many :matches, through: :match_unique_deck
  has_many :match_unique_deck

  ### CALLBACKS:

  before_save :update_stats

  ### VALIDATIONS:

  validates :cardstring, presence: true

  ### INSTANCE METHODS:

  def update_stats
    # remove existing cards
    unique_deck_card.destroy_all

    # update cards from cardstring
    cardstring.split(',').each do |card_data|
      id, count = card_data.split('_').map(&:to_i)
      count.times do
        if card = Card.find_by_id(id)
          cards << card
        end
      end
    end

    self.num_minions = cards.where(type_id: 1).count
    self.num_spells  = cards.where(type_id: 2).count
    self.num_weapons = cards.where(type_id: 3).count
    self.num_users   = self.decks.where(klass_id: klass_id).count
    self.num_matches = self.decks.sum(:user_num_matches)
    self.num_wins    = self.decks.sum(:user_num_wins)
    self.num_losses  = self.decks.sum(:user_num_losses)
    self.winrate     = (num_matches.present? && num_matches != 0) ? (num_wins.to_f / num_matches.to_f * 100) : 0
  end
end
