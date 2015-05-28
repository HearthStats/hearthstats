class Deck < ActiveRecord::Base
  attr_accessible :loses, :name, :wins, :notes, :cardstring,
                  :klass_id, :is_public, :user_id, :is_tourn_deck,
                  :deck_type_id, :archived

  acts_as_taggable
  is_impressionable
  acts_as_commontable

  extend FriendlyId
  friendly_id :name, use: :slugged

  TYPES = {
    1 => 'Constructed',
    2 => 'Arena',
    3 => 'Featured'
  }

  ### ASSOCIATIONS:

  belongs_to :unique_deck
  belongs_to :klass
  belongs_to :user

  has_many :matches, through: :match_deck, dependent: :destroy, inverse_of: :deck
  has_many :match_deck, dependent: :destroy
  has_many :deck_versions, dependent: :destroy
  has_many :constructeds
  has_many :tourn_decks

  ### CALLBACKS:

  before_save :normalize_name
  before_save :create_unique_deck, if: :cardstring_changed?
  after_save  :update_unique_deck_stats
  after_create :create_deck_version
  if !Rails.env.test?
    after_create :subscribe_user_to_deck
  end

  ### CLASS METHODS:

  # Featured Decks: 
  def self.get_featured_decks
    Deck.where(deck_type_id: 3)
  end

  def self.hdt_parse(json)
    card_array = []
    cards = Card.all
    json.each do |card|
      id = cards.select {|cardq| cardq.blizz_id == card["id"] }[0].try(:id)
      next if id.to_s == ""
      card_array << id.to_s + "_" + card["count"].to_s
    end

    card_array.join(",")
  end

  def self.archive_unused(user_obj)
    active_decks = user_obj.decks.includes(:matches)
      .merge(Match.where("matches.created_at >= ?", 1.week.ago))
    active_decks= active_decks + user_obj.decks.where("created_at >= ?", 2.weeks.ago)
    user_obj.decks.update_all(archived: true)
    active_ids = active_decks.uniq.map(&:id)
    Deck.where(id: active_ids).update_all(archived: false)
  end

  def self.bestuserdeck(user_id)
    ratings_array = []
    decks = User.find(user_id).decks
    match_count = decks.where(archived: false).map {|deck| deck.matches.count}.sum
    decks.each do |deck|
      deck_matches = deck.matches.count
      rating = deck_matches.to_f/match_count * deck.user_winrate.to_i
      next if (rating).nan?
      ratings_array << [deck, rating]
    end
    [] and return if ratings_array.empty?
    ratings_array.sort_by! {|deck| deck[1]}.last[0]
  end

  # def self.playable_decks(user_id)
  #   Deck.where(user_id: user_id, is_tourn_deck:[false, nil]).where("unique_deck_id IS NOT NULL")
  # end

  ### INSTANCE METHODS:

  def subscribe_user_to_deck
    self.thread.subscribe(self.user)
  end

  def rank_wr
    grouped = self.matches.includes(:rank).group_by {|match| match.rank}
    grouped.map {|rank| [rank[0], calculate_winrate(rank[1])]}
  end

  def get_cards
    return if self.cardstring.nil?
    card_array = []
    self.cardstring.split(",").each do |card|
      db_card = Card.find(card.split("_")[0])if !card.split("_")[0].blank?
      card_array << db_card
    end

    card_array.compact
  end

  def current_version
    self.deck_versions.
      last
  end

  def cardstring_to_blizz
    return if self.cardstring.nil?
    card_array = []
    self.cardstring.split(",").each do |card|
      blizz_id = Card.find(card.split("_")[0]).blizz_id if !card.split("_")[0].blank?
      card_array << {"id" => blizz_id, "count" => card.split("_")[1]}
    end

    card_array
  end

  def create_deck_version
    DeckVersion.create(deck_id: self.id, version: "1.0", cardstring: self.cardstring)
  end

  def deactivate_deck
    self.slot = nil
    self.active = false
    save
  end

  def archive!
    self.update_attribute(:archived, true)
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
    return if self.deck_type_id == 2
    self.cardstring = cardstring.split(",").sort.join(",")
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
    cards = Card.find(cardstring_array.map {|e| e[0]}).sort_by{ |card| [ card.mana, card.name] }
    cards.each do |card|
      quantity = cardstring_array.detect {|c| c[0].to_i == card.id }[1]
      arr << [card, quantity]
    end

    arr
  end

  private

  def update_unique_deck_stats
    if matches.count.modulo(5) == 0
      Rails.cache.delete('deck_stats' + self.id.to_s + self.current_version.try(:version).to_s)
      UniqueDeck.delay.update_stats(unique_deck_id) if unique_deck_id
    end
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
