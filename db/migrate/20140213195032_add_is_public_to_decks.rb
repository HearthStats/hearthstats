class AddIsPublicToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :is_public, :boolean
  end
end
