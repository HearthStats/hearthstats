class CreateTournies < ActiveRecord::Migration
  def change
    create_table :tournies do |t|
      t.integer :challonge_id
      t.integer :status
      t.integer :winner_id
      t.string :prize

      t.timestamps
    end
  end
end
