class AddUseridToDeck < ActiveRecord::Migration
  def change
    add_column :decks, :user_id, :integer
  end
end
