class AddDefaultValueForCachedNums < ActiveRecord::Migration
  def up
    change_column :decks, :user_num_matches, :integer, default: 0
    change_column :decks, :user_num_wins, :integer, default: 0
    change_column :decks, :user_num_losses, :integer, default: 0
    change_column :decks, :user_winrate, :float, default: 0.0

    change_column :unique_decks, :num_matches, :integer, default: 0
    change_column :unique_decks, :num_wins, :integer, default: 0
    change_column :unique_decks, :num_losses, :integer, default: 0
    change_column :unique_decks, :num_minions, :integer, default: 0
    change_column :unique_decks, :num_spells, :integer, default: 0
    change_column :unique_decks, :num_weapons, :integer, default: 0
    change_column :unique_decks, :num_users, :integer, default: 0
    change_column :unique_decks, :mana_cost, :integer, default: 0
    change_column :unique_decks, :winrate, :float, default: 0.0
  end

  def down
  end
end
