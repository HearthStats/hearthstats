class RenameClassColumnToRace < ActiveRecord::Migration
  def change
  	rename_column :decks, :class, :race
  end
end
