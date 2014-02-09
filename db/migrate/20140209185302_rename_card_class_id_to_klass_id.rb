class RenameCardClassIdToKlassId < ActiveRecord::Migration
  def change
    rename_column :cards, :class_id, :klass_id
  end
end
