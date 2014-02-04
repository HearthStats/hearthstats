class CreateMatchRun < ActiveRecord::Migration
  def change
    create_table :matchruns do |t|
    	t.integer :arenarun_id
    	t.integer :match_id

      t.timestamps
    end
  end
end
