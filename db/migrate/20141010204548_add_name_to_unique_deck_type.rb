class AddNameToUniqueDeckType < ActiveRecord::Migration
  def change
    add_column :unique_deck_types, :name, :string
  end
end
