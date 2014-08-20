class AddManaCostToUniqueDecks < ActiveRecord::Migration
  def change
    add_column :unique_decks, :mana_cost, :integer
  end
end
