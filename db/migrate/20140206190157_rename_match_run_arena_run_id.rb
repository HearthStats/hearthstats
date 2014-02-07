class RenameMatchRunArenaRunId < ActiveRecord::Migration
  def up
    rename_column :match_runs, :arenarun_id, :arena_run_id
  end

  def down
  end
end
