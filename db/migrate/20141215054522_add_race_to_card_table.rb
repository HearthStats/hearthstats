class AddRaceToCardTable < ActiveRecord::Migration
  def change
    add_column :cards, :race, :string
  end
end
