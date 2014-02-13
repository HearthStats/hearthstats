class AddUniqueDeckIdToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :unique_deck_id, :integer
  end
end
