class FractionsTable < ActiveRecord::Migration
  def change
    create_table :factions do |t|
      t.string :name
      t.timestamps
    end
 
  end
end
