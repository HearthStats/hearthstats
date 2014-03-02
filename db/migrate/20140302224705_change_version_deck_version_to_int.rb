class ChangeVersionDeckVersionToInt < ActiveRecord::Migration
  def up
    change_column :deck_versions, :version, :integer
  end

  def down
  end
end
