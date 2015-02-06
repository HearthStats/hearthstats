class ChangeCardTable < ActiveRecord::Migration
  def change
    remove_column :cards, :card_set_id
    remove_column :cards, :type_id
    remove_column :cards, :race_id
    remove_column :cards, :race

    add_column :cards, :card_set, :string
    add_column :cards, :type, :string
  end
end
