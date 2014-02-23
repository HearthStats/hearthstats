class AddNumUsersToUniqueDecks < ActiveRecord::Migration
  def change
    add_column :unique_decks, :num_users, :integer
  end
end
