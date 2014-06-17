class AddTournySections < ActiveRecord::Migration
  def change
    add_column :tournies, :title, :string
    add_column :tournies, :desc, :string
    add_column :tournies, :date, :timestamp
  end
end
