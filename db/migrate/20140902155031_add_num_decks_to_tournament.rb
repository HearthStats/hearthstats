class AddNumDecksToTournament < ActiveRecord::Migration
  def change
    add_column :tournaments, :num_decks, :integer
  end
end
