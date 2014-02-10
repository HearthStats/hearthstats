class ArenaRunKlassIdToInt < ActiveRecord::Migration
  def up
    remove_column :arena_runs, :klass_id
  end

  def down
    add_column :arena_runs, :klass_id, :integer
  end
end
