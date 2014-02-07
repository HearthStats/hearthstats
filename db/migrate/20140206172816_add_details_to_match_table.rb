class AddDetailsToMatchTable < ActiveRecord::Migration
  def change
    add_column :matches, :coin, :boolean
    add_column :matches, :numturns, :integer
    add_column :matches, :duration, :integer
  end
end
