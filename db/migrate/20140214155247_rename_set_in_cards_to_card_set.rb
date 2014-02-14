class RenameSetInCardsToCardSet < ActiveRecord::Migration
  def up
    rename_column :cards, :set_id, :card_set_id
  end

  def down
  end
end
