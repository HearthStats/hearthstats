class AddDefaultToCurrentStatToConAndArena < ActiveRecord::Migration
  def change
  	change_column :constructeds, :patch, :string, :default => "current"
  	change_column :arena_runs, :patch, :string,:default => "current"
  end
end
