class RenameDeckcardsToDeckCards < ActiveRecord::Migration
  def up
    rename_table :deckcards, :deck_cards
  end

  def down
  end
end
