class RemoveWinAndLossFromDeck < ActiveRecord::Migration
  def create
    remove_column :deck, :wins
    remove_column :deck, :loses
  end
end
