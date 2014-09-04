class AddIndexes < ActiveRecord::Migration
  def up
    # Arena Runs
    add_index :arena_run_cards, :arena_run_id
    add_index :arena_run_cards, :card_id

    # Cards
    add_index :cards, :name
    
    # Deck
    add_index :deck_versions, :deck_id 

    # Profile
    add_index :profiles, :name

    # Unique Deck
    add_index :unique_deck_cards, :unique_deck_id
    add_index :unique_deck_cards, :card_id

  end

  def down
    # Arena Runs
    add_index :arena_run_cards, :arena_run_id
    add_index :arena_run_cards, :card_id

    # Cards
    add_index :cards, :name
    
    # Deck
    add_index :deck_versions, :deck_id 

    # Profile
    add_index :profiles, :name

    # Unique Deck
    add_index :unique_deck_cards, :unique_deck_id
    add_index :unique_deck_cards, :card_id

  end

end
