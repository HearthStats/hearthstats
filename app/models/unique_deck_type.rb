class UniqueDeckType < ActiveRecord::Base
  attr_accessible :match_string, :archtype_id, :name, :klass_id

  ARCHTYPES = {
    1 => "Aggro",
    2 => "Control",
    3 => "Combo"
  }
  ### ASSOCIATIONS:

  has_many :unique_decks

  ### CLASS METHODS:

  def self.find_type(klass_id, cardstring)
    klass_types = where(klass_id: klass_id)
    return nil if klass_types.count == 0
    klass_types.each do |deck_type|
      return deck_type.id if match_type(cardstring, deck_type)
    end
  end


  def self.match_type(cardstring, deck_type)
    match_array = deck_type.match_string.split(",") if deck_type.match_string
    matched = true
    match_array.each do |card_id|
      has_card = cardstring.include? card_id
      if !has_card
        matched = false and return
      end
    end

    matched
  end

  def self.find_from_log(args)
    user = args[:user]
    return if args[:log].nil?
    logfile = JSON.parse args[:log]
    if logfile["firstPlayerName"] == user
      playerid = logfile["firstPlayer"] 
    else
      playerid = logfile["secondPlayer"]
    end
    card_array = []
    logfile["turns"][0]["actions"].each do |card|
      if card["player"] == playerid
        card_array << Card.find_by_name(card["card"]).try(:id) unless card["card"].blank?
      end
    end
    opp_cardstring = card_array.join(",")
    self.find_type(args[:klass_id], opp_cardstring)

  end
end
