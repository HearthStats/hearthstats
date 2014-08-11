class AddProfileBnetNumber < ActiveRecord::Migration
  def change
    add_column :profiles, :bnetnum, :integer
  end
end
