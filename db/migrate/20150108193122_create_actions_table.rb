class CreateActionsTable < ActiveRecord::Migration
  def up
    create_table(:actions) do |t|
      t.integer :time
      t.string :action
      t.string :card
      t.integer :card_id
      t.integer :user_id
      t.integer :match_id
      t.timestamps
    end
  end

  def down
    drop_table :actions
  end
end
