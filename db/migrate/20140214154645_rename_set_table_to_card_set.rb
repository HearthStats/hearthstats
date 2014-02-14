class RenameSetTableToCardSet < ActiveRecord::Migration
  def up
    rename_table :sets, :card_sets
  end

  def down
  end
end
