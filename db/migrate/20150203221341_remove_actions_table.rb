class RemoveActionsTable < ActiveRecord::Migration
  def change
    drop_table :actions;
  end
end
