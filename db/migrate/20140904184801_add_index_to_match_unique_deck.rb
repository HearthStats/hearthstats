class AddIndexToMatchUniqueDeck < ActiveRecord::Migration
  def change
    add_index :match_unique_decks, :unique_deck_id
    add_index :match_unique_decks, :match_id
  end
end
