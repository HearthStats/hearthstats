class Deck < ActiveRecord::Base
  attr_accessible :loses, :name, :wins, :race, :decklink, :notes, :cardstring, :klass_id, :is_public
  
  acts_as_taggable
  is_impressionable
  opinio_subjectum
  
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  ### ASSOCIATIONS:
  
  belongs_to :unique_deck
  belongs_to :klass
  belongs_to :user
  has_many :matches, through: :match_deck, dependent: :destroy
  has_many :match_deck
  has_many :deck_versions
  has_many :constructeds
  
  ### CALLBACKS:
  
  before_save :normalize_name
  before_save :create_unique_deck, if: :cardstring_changed?
  after_save  :update_unique_deck_details
  
  ### CLASS METHODS:
  
  def self.bestuserdeck(userid)
    decks = Deck.includes(:matches).where(user_id: userid)
    winrates = Hash.new
    decks.each do |d|
      if d.matches.count == 0
      else
        winrates[d.name] = [((d.matches.where(result_id: 1).count.to_f / d.matches.count)*100).round, d.id]
      end
    end
    deck = winrates.max_by { |x,y| y}
    deck
  end
  
  def self.race_count
    races = Deck.pluck(:race)
    race_groups = races.group_by { |race| race } # {"Druid" => ["Druid", "Druid"]}
    
    Hash[race_groups.map { |race, list| [race, list.size] }]
  end
  
  ### INSTANCE METHODS:
  
  def num_cards
    return  0 unless self.cardstring
    num_cards = 0
    cards = self.cardstring.split(',')
    cards.each do |card_data|
      chunks = card_data.split('_')
      num_cards += chunks[1].to_f
    end
    return num_cards
  end
  
  def create_unique_deck
    # check for 30 cards and assign unique deck
    if num_cards == 30
      unique_deck = UniqueDeck.where(cardstring: cardstring, klass_id: klass_id).first
      unless unique_deck
        unique_deck = UniqueDeck.create(cardstring: cardstring, klass_id: klass_id)
      end
      self.unique_deck_id = unique_deck.id
    end
  end
  
  def update_unique_deck_details
    # re-save the unique deck on order to trigger
    # proper pulling of data from the first fully
    # saved deck that matches the unique deck's cardstring
    unless unique_deck.nil?
      unique_deck.save
    end
  end
  
  def update_user_stats!
    self.user_num_matches = matches.count
    self.user_num_wins    = matches.where(result_id: 1).count
    self.user_num_losses  = matches.where(result_id: 2).count
    self.user_winrate     = user_num_matches > 0 ? (user_num_wins.to_f / user_num_matches) * 100 : 0
    
    save
  end
  
  def decklink_message
    
    # Add http:// to link if not present
    # If page is not a valid link then return link
    # Else return list of cards in deck
    # If Nokogiri fails to parse, return No deck link if blank
    # Else return link
    if !decklink.present?
      message = "No deck link attatched to this deck yet <p>"
    else
      link = prepend_http(decklink)
      begin
        page = Nokogiri::HTML(open(link))
        if !page.css('header').text.blank?
          message = "<a href='#{link}'>Link To Deck</a><p>"
        else
          message = page.text
        end
      rescue
        link = link[0..-10]
        message = "<a href='#{link}'>Link To Deck</a><p>"
      end
    end
    
    message
  end
  
  def class_name
    if klass.nil?
      return race
    end
    return klass.name
  end
  
  def num_users
    return self.unique_deck.nil? ? 0 : self.unique_deck.num_users
  end
  
  def num_matches
    return matches.count
  end
  def num_global_matches
    return self.unique_deck.nil? ? 0 : self.unique_deck.num_matches
  end
  
  def num_minions
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_minions
  end
  
  def num_spells
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_spells
  end
  
  def num_weapons
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_weapons
  end
  
  def wins
    return matches.where(result_id: 1).count
  end
  def global_wins
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_wins
  end
  
  def losses
    return matches.where(result_id: 2).count
  end
  def global_losses
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_losses
  end
  
  def winrate
    return num_matches > 0 ? (wins.to_f / num_matches) * 100 : 0
  end
  def global_winrate
    return self.unique_deck.nil? ? "-" : self.unique_deck.winrate
  end
  
  def copy(user)
    new_copy = Deck.new
    new_copy.name = self.name
    new_copy.unique_deck = self.unique_deck
    new_copy.user_id = user.id
    new_copy.klass = self.klass
    new_copy.notes = self.notes
    new_copy.cardstring = self.cardstring
    new_copy.is_public = true
    new_copy.save
    return new_copy
  end
  
  def get_user_copy(user)
    return Deck.where(user_id: user.id, unique_deck_id: self.unique_deck_id)[0]
  end
  
  def cards
    if self.unique_deck.nil?
      return nil
    end
    return self.unique_deck.cards
  end
  
  def card_array_from_cardstring
    cardstring_array = cardstring_as_array
    
    arr = []
    cards = Card.where("id IN (?)", cardstring_array.map {|e| e[0]}).order("mana, name")
    cards.each do |card|
      element = cardstring_array.detect {|c| c[0].to_i == card.id }
      arr << [card, element[1]]
    end
    
    arr
  end
  
  private
  
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
