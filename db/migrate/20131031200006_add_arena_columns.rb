class AddArenaColumns < ActiveRecord::Migration
  def change
  	add_column :arenas, :user_id, :integer
  	add_column :arenas, :userclass, :string, :default => "N/A"
  	add_column :arenas, :oppclass, :string, :default => "N/A"
  	add_column :arenas, :win, :boolean, :default => false

  	add_column :constructeds, :user_id, :integer
  	add_column :constructeds, :deckname, :string
  	add_column :constructeds, :oppclass, :string, :default => "N/A"
  	add_column :constructeds, :win, :boolean, :default => false

  end
end
