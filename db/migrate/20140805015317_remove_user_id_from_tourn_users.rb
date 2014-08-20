class RemoveUserIdFromTournUsers < ActiveRecord::Migration
  def change
    remove_column :tourn_users, :user_id, :integer
  end
end
