class AddSeasonAndPatchIdToMatchesAndCards < ActiveRecord::Migration
  def change
    add_column :matches, :patch_id, :integer
    add_column :matches, :season_id, :integer
    add_column :cards, :patch_id, :integer
  end
end
