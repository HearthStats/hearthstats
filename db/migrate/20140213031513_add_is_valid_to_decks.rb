class AddIsValidToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :is_valid, :boolean
  end
end
