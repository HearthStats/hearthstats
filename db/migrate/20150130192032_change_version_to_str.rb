class ChangeVersionToStr < ActiveRecord::Migration
  def up
    change_column :deck_versions, :version, :string
  end

  def down
    change_column :deck_versions, :version, :integer
  end
end
