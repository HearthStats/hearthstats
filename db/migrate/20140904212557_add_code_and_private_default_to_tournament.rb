class AddCodeAndPrivateDefaultToTournament < ActiveRecord::Migration
  def change
    add_column :tournaments, :code, :string
    change_column :tournaments, :is_private, :boolean, :default => false
  end
end
