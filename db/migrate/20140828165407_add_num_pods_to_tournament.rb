class AddNumPodsToTournament < ActiveRecord::Migration
  def change
    add_column :tournaments, :num_pods, :integer
  end
end
