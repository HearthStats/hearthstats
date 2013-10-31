class CreateConstructeds < ActiveRecord::Migration
  def change
    create_table :constructeds do |t|

      t.timestamps
    end
  end
end
