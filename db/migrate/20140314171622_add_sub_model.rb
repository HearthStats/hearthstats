class AddSubModel < ActiveRecord::Migration
  def up
    add_column :users, :subscription_id, :integer
    create_table :subscriptions do |t|
      t.string :name
      t.float :cost
    end
  end

  def down

  end
end
