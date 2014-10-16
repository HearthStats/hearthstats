class AddKlassToUniqueDeckTypeTable < ActiveRecord::Migration
  def change
    add_column :unique_deck_types, :klass_id, :integer
  end
end
