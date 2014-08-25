class RemoveUserIdFromTournUsers < ActiveRecord::Migration
  def self.up
    remove_column :tourn_users, :user_id
  end

  def self.down
    add_column :tourn_users, :user_id, :integer
  end
end