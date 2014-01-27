class ChangeUniquenessUserkey < ActiveRecord::Migration
  def up
  	change_column :users, :userkey, :string, :unique => false

  end

  def down
  end
end
