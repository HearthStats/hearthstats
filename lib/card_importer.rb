require 'httparty'
class CardImporter
  def initialize(set)
    @set = set
    @all_cards = HTTParty.get("http://hearthstonejson.com/json/AllSets.json")
  end

  def import_all
    @all_cards.each do |set|
      p "Parsing #{set[0]}"
      count = set[1].count
      set[1].each_with_index do |card, i|
        next if !["Spell", "Minion", "Weapon"].include? card["type"]
        db_card = Card.find_by_name(card["name"])
        returned_card = db_card
        if db_card.nil?
          returned_card = create_card(card)
        elsif db_card.blizz_id.length > card["id"].length
          returned_card = update_card(card, db_card)
        else
          returned_card = update_specs(card, db_card)
        end
        returned_card.update_attribute(:card_set, set[0])
        percent = i.to_f/count*100
        p percent.to_s + " %\r"
        $stdout.flush
      end
    end
  end

  private

  def update_specs(card, card_db)
    rarities = Card::RARITY.invert
    klasses = Klass::LIST.invert
    card_db.update_attributes(
      attack: card["attack"],
      health: card["health"],
      type_name: card["type"].to_s,
      rarity_id: rarities[card["rarity"]],
      klass_id: klasses[card["playerClass"]],
      mana: card["cost"],
      collectible: card["collectible"]
    )
    add_mechanics(card["mechanics"], card_db)

    card_db
  end
  def update_card(card, card_db)
    rarities = Card::RARITY.invert
    klasses = Klass::LIST.invert
    card_db.update_attributes(
      description: card["text"].to_s,
      attack: card["attack"],
      health: card["health"],
      type_name: card["type"].to_s,
      blizz_id: card["id"],
      rarity_id: rarities[card["rarity"]],
      klass_id: klasses[card["playerClass"]],
      mana: card["cost"],
      collectible: card["collectible"]
    )
    add_mechanics(card["mechanics"], card_db)

    card_db
  end

  def create_card(card)
    rarities = Card::RARITY.invert
    klasses = Klass::LIST.invert
    card_db = Card.create(
      name: card["name"].to_s,
      description: card["text"].to_s,
      attack: card["attack"],
      health: card["health"],
      type_name: card["type"].to_s,
      blizz_id: card["id"],
      rarity_id: rarities[card["rarity"]],
      klass_id: klasses[card["playerClass"]],
      mana: card["cost"],
      collectible: card["collectible"]
    )
    add_mechanics(card["mechanics"], card_db)

    card_db
  end

  def add_mechanics(mechanics, card)
    if mechanics
      new_mechs = mechanics - card.mechanics.pluck(:name)
      new_mechs.each do |mech|
        mech_db = Mechanic.find_by_name(mech)
        if mech_db.nil?
          mech_db = Mechanic.create(name: mech)
        end
      end
    end
  end
end
