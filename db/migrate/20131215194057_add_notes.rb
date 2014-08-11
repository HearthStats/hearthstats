class AddNotes < ActiveRecord::Migration
  def change
    add_column :decks, :notes, :text
    add_column :constructeds, :notes, :text
    add_column :arenas, :notes, :text
  end
end
