class DropUnusedTables < ActiveRecord::Migration
  def up
    drop_table :active_admin_comments
    drop_table :activities
    drop_table :admin_users
    drop_table :annoucements
    drop_table :constructeds
    drop_table :tourn_decks
    drop_table :tourn_matches
    drop_table :tourn_pairs
    drop_table :tourn_users
    drop_table :tournaments
    drop_table :tournies
  end

  def down
  end
end
