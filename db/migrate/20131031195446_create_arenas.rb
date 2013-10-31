class CreateArenas < ActiveRecord::Migration
  def change
    create_table :arenas do |t|

      t.timestamps
    end
  end
end
