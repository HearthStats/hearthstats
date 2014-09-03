class AddStartedToTournament < ActiveRecord::Migration
  def change
    add_column :tournaments, :started, :boolean
  end
end
