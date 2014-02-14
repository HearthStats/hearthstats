class ChangePatchToString < ActiveRecord::Migration
  def up
    change_column :patches, :num, :string
  end

  def down
  end
end
