class AddNoEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :no_email, :boolean, default: false
  end
end
