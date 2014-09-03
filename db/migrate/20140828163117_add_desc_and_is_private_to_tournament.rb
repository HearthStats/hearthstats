class AddDescAndIsPrivateToTournament < ActiveRecord::Migration
  def change
    add_column :tournaments, :desc, :string
    add_column :tournaments, :is_private, :boolean
  end
end
