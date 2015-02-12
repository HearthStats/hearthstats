class AddIndexToMatches < ActiveRecord::Migration
  def change
    add_index :matches, :season_id
  end
end
