class AddTypeTable < ActiveRecord::Migration
  def up
    create_table :types do |t|
      t.string :name
    end
  end

  def down
  end
end
