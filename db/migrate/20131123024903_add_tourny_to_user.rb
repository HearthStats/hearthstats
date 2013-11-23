class AddTournyToUser < ActiveRecord::Migration
  def change
    add_column :users, :tourny_id, :integer
    add_index :users, :tourny_id
  end
end
