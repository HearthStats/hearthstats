class AddNotesToArenaRuns < ActiveRecord::Migration
  def change
  	add_column :arena_runs, :notes, :text
  end
end
