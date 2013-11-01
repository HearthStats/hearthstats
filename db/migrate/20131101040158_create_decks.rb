class CreateDecks < ActiveRecord::Migration
  def change
    create_table :decks do |t|
      t.string :name
      t.integer :wins
      t.integer :loses

      t.timestamps
    end
  end
end
