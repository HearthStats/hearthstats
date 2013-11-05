class Addfirstturntoarenanadconstructed < ActiveRecord::Migration
  def change
  	add_column :constructeds, :gofirst, :boolean,  :default => true
  	add_column :arenas, :gofirst, :boolean,  :default => true
  end
end
