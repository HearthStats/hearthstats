class RankedGameCon < ActiveRecord::Migration
  def change
    add_column :constructeds, :rank, :string
  end
end
