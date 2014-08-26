class AddUserRefToTournUsers < ActiveRecord::Migration
  def change
    add_column :tourn_users, :user_id, :integer
    add_index :tourn_users, :user_id
  end
end
