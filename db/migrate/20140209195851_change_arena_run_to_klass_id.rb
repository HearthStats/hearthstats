class ChangeArenaRunToKlassId < ActiveRecord::Migration
  def up
    rename_column :arena_runs, :userclass, :klass_id
  end

  def down
  end
end
