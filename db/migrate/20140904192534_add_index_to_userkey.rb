class AddIndexToUserkey < ActiveRecord::Migration
  def change
    add_index :users, :userkey
  end
end
