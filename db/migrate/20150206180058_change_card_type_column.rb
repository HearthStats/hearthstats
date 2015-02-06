class ChangeCardTypeColumn < ActiveRecord::Migration
  def change
    rename_column :cards, :type, :type_name
  end
end
