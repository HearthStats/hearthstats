class CreateTournDecks < ActiveRecord::Migration
  def change
    create_table :tourn_decks do |t|
      t.belongs_to :tournament
      t.belongs_to :tourn_user
      t.integer :deck_id

      t.timestamps
    end
  end
end
