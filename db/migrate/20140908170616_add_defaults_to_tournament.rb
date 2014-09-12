class AddDefaultsToTournament < ActiveRecord::Migration
  def change
    change_column :tournaments, :started, :boolean, default: false
    change_column :tournaments, :num_decks, :integer, default: 3
  end
end
