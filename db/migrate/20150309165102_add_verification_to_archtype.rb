class AddVerificationToArchtype < ActiveRecord::Migration
  def change
    add_column :unique_deck_types, :verified, :boolean, default: false
  end
end
