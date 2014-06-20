class AddMissingIndices < ActiveRecord::Migration
  def up
    add_index :unique_decks, :cardstring
    add_index :cards, :type_id
    add_index :decks, :unique_deck_id
  end

  def down
    remove_index :unique_decks, :cardstring
    remove_index :cards, :type_id
    remove_index :decks, :unique_deck_id
  end
end
