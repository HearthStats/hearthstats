class AddDefaultToProfileBnetNumber < ActiveRecord::Migration
  def change
  	change_column :profiles, :bnetnum, :integer, :default => 0
  end
end
