class AddBlizzIdToCardsTable < ActiveRecord::Migration
  def change
    add_column :cards, :blizz_id, :string
  end
end
