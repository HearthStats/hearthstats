class AddDeckListToDecks < ActiveRecord::Migration
  def change
    create_table :deckversion do |t|
      t.belongs_to :deck
      t.string :cardstring
      t.text :notes
      t.timestamps
    end
  end
end
