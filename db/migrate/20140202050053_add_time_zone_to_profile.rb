class AddTimeZoneToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :time_zone, :string, :default => "UTC"
  end
end
