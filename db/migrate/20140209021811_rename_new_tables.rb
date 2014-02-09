class RenameNewTables< ActiveRecord::Migration
  def change
    rename_table :card, :cards
    rename_table :patch, :patches
    rename_table :season, :seasons
    rename_table :rarity, :rarities
    rename_table :deckversion, :deckversions
  end
end
