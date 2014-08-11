class AddCurrentStatToConAndArena < ActiveRecord::Migration
  def change
    add_column :arena_runs, :patch, :string
    add_column :constructeds, :patch, :string
  end
end
