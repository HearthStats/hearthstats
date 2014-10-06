class SetIsTournDeckDefaultInDeck < ActiveRecord::Migration
  def change
    change_column_default :decks, :is_tourn_deck, false
  end
end
