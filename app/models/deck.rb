class Deck < ActiveRecord::Base
  attr_accessible :loses, :name, :wins, :notes, :cardstring,
                  :klass_id, :is_public, :user_id, :is_tourn_deck

  acts_as_taggable
  is_impressionable
  opinio_subjectum
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }

  extend FriendlyId
  friendly_id :name, use: :slugged

  ### ASSOCIATIONS:

  belongs_to :unique_deck
  belongs_to :klass
  belongs_to :user

  has_many :matches, through: :match_deck, dependent: :destroy, inverse_of: :deck
  has_many :match_deck
  has_many :deck_versions
  has_many :constructeds
  has_many :tourn_decks

  ### CALLBACKS:

  before_save :normalize_name
  before_save :create_unique_deck, if: :cardstring_changed?
  after_save  :update_unique_deck_stats

  ### CLASS METHODS:

  def self.bestuserdeck(user_id)
    Deck.where(user_id: user_id).order("user_winrate DESC").first
  end

  def self.playable_decks(user_id)
    Deck.where(user_id: user_id, is_tourn_deck:[false, nil]).where("unique_deck_id IS NOT NULL")
  end
  ### INSTANCE METHODS:

  def deactivate_deck
    self.slot = nil
    self.active = false
    save
  end

  def active?
    self.active == true && self.slot != nil
  end

  def num_cards
    return 0 unless cardstring
    num_cards = 0
    cards = cardstring.split(',')
    cards.each do |card_data|
      chunks = card_data.split('_')
      num_cards += chunks[1].to_f
    end
    return num_cards
  end

  def create_unique_deck
    self.unique_deck = UniqueDeck.create_from_deck(self) if num_cards == 30
  end

  def update_user_stats!
    self.user_num_matches = matches.count
    self.user_num_wins    = matches.where(result_id: 1).count
    self.user_num_losses  = matches.where(result_id: 2).count
    self.user_winrate     = user_num_matches > 0 ? (user_num_wins.to_f / user_num_matches) * 100 : 0

    save
  end

  def class_name
    Klass::LIST[klass_id]
  end

  def klass
    Klass.all_klasses.find{|k| k.id == klass_id }
  end

  def num_users
    return self.unique_deck.nil? ? 0 : self.unique_deck.num_users
  end

  def num_matches
    return matches.count
  end

  def num_global_matches
    return unique_deck.nil? ? 0 : unique_deck.num_matches
  end

  def num_minions
    return unique_deck.nil? ? "-" : unique_deck.num_minions
  end

  def num_spells
    return unique_deck.nil? ? "-" : unique_deck.num_spells
  end

  def num_weapons
    return unique_deck.nil? ? "-" : unique_deck.num_weapons
  end

  def wins
    return matches.where(result_id: 1).count
  end

  def global_wins
    return unique_deck.nil? ? "-" : unique_deck.num_wins
  end

  def losses
    return matches.where(result_id: 2).count
  end

  def global_losses
    return unique_deck.nil? ? "-" : unique_deck.num_losses
  end

  def winrate
    return num_matches > 0 ? (wins.to_f / num_matches) * 100 : 0
  end

  def global_winrate
    return unique_deck.nil? ? "-" : unique_deck.winrate
  end

  def copy(user)
    new_copy             = Deck.new

    new_copy.name        = name
    new_copy.unique_deck = unique_deck
    new_copy.user_id     = user.id
    new_copy.klass       = klass
    new_copy.notes       = notes
    new_copy.cardstring  = cardstring
    new_copy.is_public   = true

    new_copy.save

    new_copy
  end

  def get_user_copy(user)
    return user.decks.find_by_unique_deck_id(unique_deck_id)
  end

  def cards
    if unique_deck.nil?
      return nil
    end
    return unique_deck.cards
  end

  def card_array_from_cardstring
    cardstring_array = cardstring_as_array

    arr = []
    cards = Card.where("id IN (?)", cardstring_array.map {|e| e[0]}).order("mana, name")
    cards.each do |card|
      element = cardstring_array.detect {|c| c[0].to_i == card.id }
      arr << [card, element[1]]
    end

    arr.sort_by { |c| c[0].mana }
  end

  private

  def update_unique_deck_stats
    UniqueDeck.delay.update_stats(unique_deck_id) if unique_deck_id
  end

  def cardstring_as_array
    # Guarding for an empty cardstring
    return [] if cardstring.nil?

    cardstring.split(",").map do |card_data|
      card_data.split('_').map(&:to_i)
    end
  end

  def prepend_http(url)
    url = "http://" + url if URI.parse(url).scheme.nil?

    url
  end

  def normalize_name
    self.name.strip! unless name.nil?
    self.name = "[unnamed]" if name.blank?
  end
end
