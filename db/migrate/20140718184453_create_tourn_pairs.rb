class CreateTournPairs < ActiveRecord::Migration
  def change
    create_table :tourn_pairs do |t|
      t.belongs_to :tournament
      t.integer :roundof
      t.integer :pos
      t.integer :p1_id
      t.integer :p2_id
      t.boolean :winners
      t.integer :winner_id

      t.timestamps
    end

    add_attachment :tourn_pairs, :screenshot
  end
end
