class ChangeNameDeckVersionToVersion < ActiveRecord::Migration
  def up
    rename_column :deck_versions, :name, :version
  end

  def down
  end
end
