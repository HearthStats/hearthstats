class AddNameToSeasons < ActiveRecord::Migration
  def change
    add_column :seasons, :name, :string
  end
end
