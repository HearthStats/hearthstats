class AddDeckTypeToDecks < ActiveRecord::Migration
  def change
    remove_column :decks, :is_tourn_deck
    add_column :decks, :deck_type_id, :integer
  end
end
