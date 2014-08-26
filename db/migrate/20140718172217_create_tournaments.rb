class CreateTournaments < ActiveRecord::Migration
  def change
    create_table :tournaments do |t|
      t.string :name
      t.datetime :start_date
      t.integer :creator_id
      t.integer :bracket_format
      t.integer :num_players

      t.timestamps
    end
  end
end
