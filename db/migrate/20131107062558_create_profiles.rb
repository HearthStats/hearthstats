class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.string :bnetid, :unique => true
      t.boolean :private, :default => false

      t.timestamps
    end
  end
end
