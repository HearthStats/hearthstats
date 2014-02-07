class AddKlassIdToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :klass_id, :integer
    add_index :decks, :klass_id
    add_index :match_decks, :deck_id
    add_index :match_decks, :match_id
    add_index :match_ranks, :rank_id
    add_index :match_ranks, :match_id
    add_index :match_results, :match_id
    add_index :match_runs, :match_id
    add_index :match_runs, :arena_run_id
    add_index :matches, :user_id
    add_index :matches, :klass_id
    add_index :matches, :oppclass_id
    add_index :matches, :mode_id
    add_index :matches, :result_id
  end
end
