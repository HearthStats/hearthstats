class CreateAnnoucements < ActiveRecord::Migration
  def change
    create_table :annoucements do |t|
      t.string :description

      t.timestamps
    end
  end
end
