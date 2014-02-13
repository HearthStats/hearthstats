class CreateUniqueDecks < ActiveRecord::Migration
  def change
    create_table :unique_decks do |t|
      t.string :cardstring
      t.integer :klass_id
      t.integer :num_matches
      t.integer :num_wins
      t.integer :num_losses
      t.integer :num_minions
      t.integer :num_spells
      t.integer :num_weapons
      t.timestamp :last_played

      t.timestamps
    end
  end
end
