class RestructureTournMatchesAgain < ActiveRecord::Migration
  def up
    remove_column :tourn_matches, :p1_match
    remove_column :tourn_matches, :p2_match
    add_column :tourn_matches, :tourn_user_id, :integer
    add_column :tourn_matches, :coin, :boolean
    add_column :tourn_matches, :round, :integer
    add_column :tourn_matches, :tourn_deck_id, :integer
  end

  def down
    add_column :tourn_matches, :p1_match, :integer
    add_column :tourn_matches, :p2_match, :integer
    remove_column :tourn_matches, :tourn_user_id
    remove_column :tourn_matches, :coin
    remove_column :tourn_matches, :round
    remove_column :tourn_matches, :tourn_deck_id
  end
end
