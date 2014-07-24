class CreateTournMatches < ActiveRecord::Migration
  def change
    create_table :tourn_matches do |t|
      t.belongs_to :tourn_pair
      t.integer :p1_tourndeck_id
      t.integer :p2_tourndeck_id

      t.timestamps
    end
  end
end
