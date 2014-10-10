class UniqueDeckType < ActiveRecord::Base
  attr_accessible :match_string, :archtype_id

  ### ASSOCIATIONS:

  has_many :unique_decks


  ### CLASS METHODS:

  def self.find_type(unique_deck)
    klass_types = UniqueDeckType.where(klass_id: unique_deck.klass_id)
    klass_types.each do |deck_type|
      self.match_type(unique_deck.cardstring, deck_type)
    end

  end

  def self.match_type(cardstring, deck_type)
    deck_type.match_string.split(",").each do |card_id|
      return unless cardstring.include? card_id
    end
  end
end
