class AddOpparchtypeToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :opp_archtype_id, :integer
  end
end
