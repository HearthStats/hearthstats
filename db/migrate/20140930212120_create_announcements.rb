class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.text :body
      t.text :heading
      t.string :type

      t.timestamps
    end
  end
end
