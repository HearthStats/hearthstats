class CreateMatchUniqueDecks < ActiveRecord::Migration
  def change
    create_table :match_unique_decks do |t|
      t.integer :unique_deck_id
      t.integer :match_id

      t.timestamps
    end
  end
end
