class RenameApikeyToUserkey < ActiveRecord::Migration
  def up
  	rename_column :users, :apikey, :userkey
  end

  def down
  end
end
