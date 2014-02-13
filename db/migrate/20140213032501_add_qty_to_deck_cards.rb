class AddQtyToDeckCards < ActiveRecord::Migration
  def change
    add_column :deck_cards, :qty, :integer
  end
end
