class AddClassToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :class, :string
  end
end
