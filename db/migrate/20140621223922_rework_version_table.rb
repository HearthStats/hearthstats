class ReworkVersionTable < ActiveRecord::Migration
  def up
    remove_column :deck_versions, :unique_deck_id
    add_column :deck_versions, :cardstring, :string
  end

  def down
  end
end
