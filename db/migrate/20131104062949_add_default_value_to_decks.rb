class AddDefaultValueToDecks < ActiveRecord::Migration
  def change
  	change_column :decks, :wins, :integer, :default => 0
  	change_column :decks, :loses, :integer, :default => 0
  end
end
