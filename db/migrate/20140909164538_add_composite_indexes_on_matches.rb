class AddCompositeIndexesOnMatches < ActiveRecord::Migration
  def up
    remove_index :matches, :user_id
    add_index :matches, [:user_id, :mode_id, :klass_id, :oppclass_id, :coin, :created_at], :name => "index_for_search"
  end

  def down
    remove_index :matches, :name => "index_for_search"
    add_index :matches, :user_id
  end
end
