class AddCreatedAtIndexOnMatchDecks < ActiveRecord::Migration
  def change
    add_index :match_decks, :created_at, name: 'index_match_decks_on_created_at'
  end
end
