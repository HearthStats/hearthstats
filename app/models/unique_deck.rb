class UniqueDeck < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  
  attr_accessible :cardstring, :name, :user_id, :num_matches, :winrate, :num_users, :klass_id

  is_impressionable

  acts_as_taggable

  ### ASSOCIATIONS:

  has_many :decks
  has_many :deck_versions

  has_many :matches, through: :match_unique_decks
  has_many :match_unique_decks

  has_many :unique_deck_cards
  has_many :cards, through: :unique_deck_cards

  belongs_to :unique_deck_type

  ### CALLBACKS:
  before_save :check_unique_deck_type
  after_create :create_cards_from_cardstring, if: :cardstring

  ### VALIDATIONS:

  validates :cardstring, presence: true

  ### CLASS METHODS

  def self.update_stats(id)
    unique_deck = UniqueDeck.find(id)
    unique_deck.update_stats! if unique_deck
  end

  def self.create_from_deck(deck)
    unique_deck = UniqueDeck.where(cardstring: deck.cardstring, klass_id: deck.klass_id).first
    if unique_deck.nil?
      unique_deck = create(cardstring: deck.cardstring, klass_id: deck.klass_id )
    end

    unique_deck
  end

  ### INSTANCE METHODS:

  # def matches
  #   all_matches = decks.map { |m| m.matches }.flatten
  #   Match.where("id IN (#{all_matches.map(&:id).join(',')})")
  # end
  
  def check_unique_deck_type
    if self.unique_deck_type_id.blank?
      self.set_type
    end
  end

  def update_stats!
    update_stats
    save
  end

  def update_stats
    self.num_minions = cards.where(type_name: "Minion").count
    self.num_spells  = cards.where(type_name: "Spell").count
    self.num_weapons = cards.where(type_name: "Weapon").count
    self.num_users   = decks.where(klass_id: klass_id).count
    self.num_matches = decks.sum(:user_num_matches)
    self.num_wins    = decks.sum(:user_num_wins)
    self.num_losses  = decks.sum(:user_num_losses)
    self.winrate     = (num_matches.present? && num_matches != 0) ? (num_wins.to_f / num_matches.to_f * 100) : 0
    self.mana_cost = get_mana_cost
  end

  def get_mana_cost
    sum = 0
    self.cards.each do |card|
      next if card.card_set == "Basic"
      cost = case card.rarity_id
      when 1
        0
      when 2
        40
      when 3
        100
      when 4
        400
      else
        1600
      end

      sum += cost
    end

    sum
  end

  def create_cards_from_cardstring
    cardstring.split(',').each do |card_data|
      id, count = card_data.split('_').map(&:to_i)
      count.times do
        unique_deck_cards.create(card_id: id)
      end
    end

    self.unique_deck_type_id = UniqueDeckType.find_type(self.klass_id, self.cardstring)
    self.save
  end

  def set_type
    self.unique_deck_type_id = UniqueDeckType.find_type(self.klass_id, self.cardstring)
  end
end
