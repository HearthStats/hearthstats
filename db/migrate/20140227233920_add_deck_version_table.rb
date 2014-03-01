class AddDeckVersionTable < ActiveRecord::Migration
  def change
    create_table :deck_versions do |t|
      t.belongs_to :deck
      t.belongs_to :unique_deck
      t.text :notes
      t.string :name

      t.timestamps
    end
  end
end
