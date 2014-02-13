class RenameDeckCardsToUnqiqueDeckCards < ActiveRecord::Migration
  def up
    rename_column :deck_cards, :deck_id, :unique_deck_id
    rename_table :deck_cards, :unique_deck_cards
  end

  def down
  end
end
