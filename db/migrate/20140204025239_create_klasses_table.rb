class CreateKlassesTable < ActiveRecord::Migration
  def change
    create_table :klasses do |t|
      t.string :name

      t.timestamps
    end
  end
end
