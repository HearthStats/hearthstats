class AddIsTourDeckToDeck < ActiveRecord::Migration
  def change
    add_column :decks, :is_tour_deck, :boolean
  end
end
