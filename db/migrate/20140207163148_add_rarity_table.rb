class AddRarityTable < ActiveRecord::Migration
  def change
    create_table :rarity do |t|
      t.belongs_to :card
      t.string :rarity
      t.timestamps
    end
  end
end
