class RestructureTournMatchesAgain < ActiveRecord::Migration
  def up
    add_column :tourn_matches, :tourn_user_id, :integer
    add_column :tourn_matches, :coin, :boolean
    add_column :tourn_matches, :round, :integer
    add_column :tourn_matches, :tourn_deck_id, :integer
  end

  def down
    remove_column :tourn_matches, :tourn_user_id
    remove_column :tourn_matches, :coin
    remove_column :tourn_matches, :round
    remove_column :tourn_matches, :tourn_deck_id
  end
end
