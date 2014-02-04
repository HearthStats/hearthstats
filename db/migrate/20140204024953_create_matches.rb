class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
    	t.integer :user_id
    	t.integer :class_id
    	t.integer :oppclass_id
    	t.string :oppname
    	t.integer :mode_id
    	t.integer :result_id
    	t.text :notes

      t.timestamps
    end
  end
end
