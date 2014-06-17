class AddTournyPic < ActiveRecord::Migration
  def up
    add_column :tournies, :pic_link, :string
  end

  def down
  end
end
