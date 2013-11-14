class ArenaRunUserIdStringToInt < ActiveRecord::Migration
  def change
  	change_column :arena_runs, :user_id, :integer
  end
end
