class AddLegendaryToMatchRank < ActiveRecord::Migration
  def change
  	add_column :match_ranks, :legendary, :integer
  end
end
