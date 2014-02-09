class AddSetTable < ActiveRecord::Migration
  def up
    create_table :sets do |t|
      t.string :name
      t.text :notes
    end
  end

  def down
  end
end
