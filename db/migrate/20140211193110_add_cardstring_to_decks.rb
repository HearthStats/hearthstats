class AddCardstringToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :cardstring, :string
  end
end
