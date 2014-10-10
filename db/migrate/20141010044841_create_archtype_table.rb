class CreateArchtypeTable < ActiveRecord::Migration
  def up
    create_table :unique_deck_types do |t|
      t.string :match_string
      t.integer :archtype_id


      t.timestamps
    end

    add_column :unique_decks, :unique_deck_type_id, :integer
  end

  def down
    remove_table :unique_deck_types
    remove_column :unique_decks, :unique_deck_type_id
  end
end
