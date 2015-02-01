class AddDeckVersionIdToMatchDeck < ActiveRecord::Migration
  def change
    add_column :match_decks, :deck_version_id, :integer
    add_index :match_decks, :deck_version_id
  end
end
