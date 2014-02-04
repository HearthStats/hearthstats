class CreateMatchRank < ActiveRecord::Migration
  def change
    create_table :matchranks do |t|
    	t.integer :rank_id
    	t.integer :match_id

      t.timestamps
    end
  end
end
