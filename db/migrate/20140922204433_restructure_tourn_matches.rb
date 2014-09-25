class RestructureTournMatches < ActiveRecord::Migration
  def up
    add_column :tourn_matches, :p1_match, :integer
    add_column :tourn_matches, :p2_match, :integer
    remove_column :tourn_matches, :p1_tourndeck_id, :integer
    remove_column :tourn_matches, :p2_tourndeck_id, :integer
    add_column :tourn_matches, :result_id, :integer
  end

  def down
    add_column :tourn_matches, :p1_tourndeck_id, :integer
    add_column :tourn_matches, :p2_tourndeck_id, :integer
    remove_column :tourn_matches, :p1_match, :integer
    remove_column :tourn_matches, :p2_match, :integer
    remove_column :tourn_matches, :result_id, :integer
  end
end
