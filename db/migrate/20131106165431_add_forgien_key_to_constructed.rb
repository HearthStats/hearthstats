class AddForgienKeyToConstructed < ActiveRecord::Migration
  def change
  	add_column :constructeds, :deck_id, :integer
  end
end