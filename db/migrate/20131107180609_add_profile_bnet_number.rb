class AddProfileBnetNumber < ActiveRecord::Migration
  def change
  	add_column :profile, :bnetnum, :integer
  end
end
