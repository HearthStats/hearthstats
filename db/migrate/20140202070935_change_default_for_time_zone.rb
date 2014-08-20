class ChangeDefaultForTimeZone < ActiveRecord::Migration
  def up
    change_column :profiles, :time_zone, :string, :default => "(GMT-05:00) Eastern Time (US & Canada)"
  end

  def down
  end
end
