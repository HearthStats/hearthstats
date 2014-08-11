class DefaultRankedValue < ActiveRecord::Migration
  def change
    change_column :constructeds, :rank, :string, :default => "Casual"
  end
end
