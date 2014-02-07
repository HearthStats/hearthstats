class RenameClasstoKlass < ActiveRecord::Migration
  def up
    rename_column :matches, :class_id, :klass_id
  end

  def down
  end
end
