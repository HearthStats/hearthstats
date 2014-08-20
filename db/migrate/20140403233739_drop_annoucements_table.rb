class DropAnnoucementsTable < ActiveRecord::Migration
  def up
    drop_table :announcements
  end

  def down
  end
end
