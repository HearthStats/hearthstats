class DeckVersion < ActiveRecord::Base
  attr_accessible :version, :notes, :deck_id, :cardstring

  ### ASSOCIATIONS:

  belongs_to :deck
  belongs_to :unique_deck
  before_save :sort_cardstring

  def sort_cardstring
    self.cardstring = cardstring.split(",").sort.join(",") if self.cardstring
  end

  def cardstring_to_blizz
    card_array = []
    self.cardstring.split(",").each do |card|
      blizz_id = Card.find(card.split("_")[0]).blizz_id if !card.split("_")[0].blank?
      card_array << {"id" => blizz_id, "count" => card.split("_")[1]}
    end

    card_array
  end
end
