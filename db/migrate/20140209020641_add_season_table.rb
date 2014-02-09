class AddSeasonTable < ActiveRecord::Migration
  def up
    create_table :season do |t|
      t.integer :num
      t.timestamps
    end 
  end

  def down
  end
end
