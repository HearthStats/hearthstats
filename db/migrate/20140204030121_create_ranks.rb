class CreateRanks < ActiveRecord::Migration
  def change
    create_table :ranks do |t|
    	t.string :name
    	t.integer :order
      t.timestamps
    end
  end
end
