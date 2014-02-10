class AddKlassIdArenaRun < ActiveRecord::Migration
  def up
    add_column :arena_runs, :klass_id, :integer
  end

  def down
  end
end
