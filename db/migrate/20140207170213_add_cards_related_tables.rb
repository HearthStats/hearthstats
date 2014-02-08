class AddCardsRelatedTables < ActiveRecord::Migration
  def up
    create_table :card do |t|
      t.string :name
      t.string :description
      t.integer :attack
      t.integer :health
      t.integer :set_id
      t.integer :rarity_id
      t.integer :type_id
      t.integer :class_id
      t.integer :race_id
      t.integer :mana
      t.boolean :collectible
      t.string :image_link
    end
  end

  def down
  end
end
