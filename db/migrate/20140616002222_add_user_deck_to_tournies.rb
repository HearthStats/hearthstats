class AddUserDeckToTournies < ActiveRecord::Migration
  def change
    add_column :tournies, :user_decks_id, :integer
  end
end
