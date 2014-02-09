class AddPatchTable < ActiveRecord::Migration
  def up
    create_table :patch do |t|
      t.integer :num
      t.text :changelog
      t.timestamps
    end 
  end

  def down
  end
end
