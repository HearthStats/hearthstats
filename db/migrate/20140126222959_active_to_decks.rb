class ActiveToDecks < ActiveRecord::Migration
  def up
  	add_column :decks, :active, :boolean
  end

  def down
  end
end
