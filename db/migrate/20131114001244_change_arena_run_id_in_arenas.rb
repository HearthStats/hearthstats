class ChangeArenaRunIdInArenas < ActiveRecord::Migration
  def change
    rename_column :arenas, :arenarun_id, :arena_run_id
  end
end
