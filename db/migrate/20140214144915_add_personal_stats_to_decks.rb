class AddPersonalStatsToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :user_num_matches, :integer
    add_column :decks, :user_num_wins, :integer
    add_column :decks, :user_num_losses, :integer
    add_column :decks, :user_winrate, :float
  end
end
