class ChangeTimeZoneToUtc < ActiveRecord::Migration
  def up
    change_column :profiles, :time_zone, :string, :default => "EST"
  end

  def down
  end
end
