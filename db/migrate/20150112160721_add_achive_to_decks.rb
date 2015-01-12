class AddAchiveToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :archived, :boolean, default: false
  end
end
