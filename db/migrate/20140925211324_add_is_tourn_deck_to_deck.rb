class AddIsTournDeckToDeck < ActiveRecord::Migration
  def change
    add_column :decks, :is_tourn_deck, :boolean
  end
end
