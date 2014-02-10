class RenameFactionsToRaces < ActiveRecord::Migration
  def up
    rename_table :factions, :races
  end

  def down
    rename_table :races, :factions
  end
end
