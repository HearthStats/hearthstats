class CreateMatchDeck < ActiveRecord::Migration
  def change
    create_table :matchdecks do |t|
    	t.integer :deck_id
    	t.integer :match_id

      t.timestamps
    end
  end
end
