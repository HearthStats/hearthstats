class AddIndexOnBlizzid < ActiveRecord::Migration
  def change
    add_index :cards, :blizz_id
  end
end
