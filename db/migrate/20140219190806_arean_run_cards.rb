class AreanRunCards < ActiveRecord::Migration
  def change
    create_table :arena_run_cards do |t|
      t.integer :arena_run_id
      t.integer :card_id
      t.boolean :golden

      t.timestamps
    end

  end
end
