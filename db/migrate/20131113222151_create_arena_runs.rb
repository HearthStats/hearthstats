class CreateArenaRuns < ActiveRecord::Migration
  def change
    create_table :arena_runs do |t|
      t.string :user_id
      t.string :userclass
      t.integer :gold, :default => 0
      t.integer :dust, :default => 0
      t.boolean :complete, :default => false

      t.timestamps
    end
    add_column :arenas, :arenarun_id, :integer
  end
end
