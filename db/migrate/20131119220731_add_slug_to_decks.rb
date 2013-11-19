class AddSlugToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :slug, :string
    add_index :decks, :slug

    add_index :arena_runs, :user_id
    add_index :arenas, :user_id
    add_index :arenas, :arena_run_id
    add_index :constructeds, :deck_id
    add_index :constructeds, :user_id
    add_index :decks, :user_id
    add_index :profiles, :user_id
  end
end
