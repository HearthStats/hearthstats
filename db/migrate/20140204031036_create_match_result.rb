class CreateMatchResult < ActiveRecord::Migration
  def change
    create_table :matchresults do |t|
    	t.integer :match_id
    	t.string :result

      t.timestamps
    end
  end
end
