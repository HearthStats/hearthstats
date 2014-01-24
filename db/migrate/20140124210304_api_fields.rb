class ApiFields < ActiveRecord::Migration
  def change
  	add_column :users, :apikey, :string, :unique => true
  	add_column :decks, :slot, :integer
  end
end
