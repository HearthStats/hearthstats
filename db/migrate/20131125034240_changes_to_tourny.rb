class ChangesToTourny < ActiveRecord::Migration
  def change
    change_column :tournies, :status, :integer, :default => 0
    add_column :tournies, :complete, :boolean, :default => 0
  end
end
