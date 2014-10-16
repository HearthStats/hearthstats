class UniqueDeckType < ActiveRecord::Base
  attr_accessible :match_string, :archtype_id, :name

  ARCHTYPES = {
    1 => "Aggro",
    2 => "Control",
    3 => "Combo"
  }
  ### ASSOCIATIONS:

  has_many :unique_decks

  ### CLASS METHODS:

  def self.find_type(unique_deck)
    klass_types = where(klass_id: unique_deck.klass_id)
    return nil if klass_types.count == 0
    klass_types.each do |deck_type|
      return deck_type.id if match_type(unique_deck.cardstring, deck_type)
    end
  end

  def self.match_type(cardstring, deck_type)
    match_array = deck_type.match_string.split(",")
    matched = true
    match_array.each do |card_id|
      has_card = cardstring.include? card_id
      if !has_card
        matched = false and return
      end
    end

    matched
  end
end
