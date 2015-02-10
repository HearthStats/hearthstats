class AddDefaultDeckTypeAndDeckId < ActiveRecord::Migration
  def change
    change_column :decks, :deck_type_id, :integer, :default => 1
    add_column :arena_runs, :deck_id, :integer

    add_index :decks, :deck_type_id
    add_index :arena_runs, :deck_id
  end
end
