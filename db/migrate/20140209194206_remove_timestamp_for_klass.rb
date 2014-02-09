class RemoveTimestampForKlass < ActiveRecord::Migration
  def up
    remove_column :klasses, :created_at
    remove_column :klasses, :updated_at
    remove_column :modes, :updated_at
    remove_column :modes, :created_at
  end

  def down
  end
end
