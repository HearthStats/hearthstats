class AddIsPublicToDecks < ActiveRecord::Migration
  def change
    add_column :unique_decks, :winrate, :float
  end
end
