class AddBestOfToTournament < ActiveRecord::Migration
  def change
    add_column :tournaments, :best_of, :integer
  end
end
