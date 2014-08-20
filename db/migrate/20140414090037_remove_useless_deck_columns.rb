class RemoveUselessDeckColumns < ActiveRecord::Migration
  def up
    remove_column :decks, :race
    remove_column :decks, :decklink
    remove_column :decks, :wins
    remove_column :decks, :loses
  end

  def down
  end
end
