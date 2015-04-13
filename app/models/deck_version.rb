class DeckVersion < ActiveRecord::Base
  attr_accessible :version, :notes, :deck_id, :cardstring

  ### ASSOCIATIONS:

  belongs_to :deck
  belongs_to :unique_deck
  before_save :sort_cardstring

  ### INSTANCE METHODS

  def newer_version
    all_versions = self.deck.deck_versions
    current_version = self.version
    minor = current_version.to_f + 0.1
    major = current_version.to_i + 1
    if has_version?(all_versions, minor.round(1).to_s)
      p "asd"
      has_version?(all_versions, minor.round(1).to_s)
    elsif has_version?(all_versions, major.to_s)
      has_version?(all_versions, major.to_s)
    else
      self
    end
  end

  def sort_cardstring
    self.cardstring = cardstring.split(",").sort.join(",") if self.cardstring
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

  def has_version?(all_versions, version_string)
    all_versions.find { |q| q.version == version_string }
  end
end
