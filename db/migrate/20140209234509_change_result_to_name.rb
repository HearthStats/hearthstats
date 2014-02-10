class ChangeResultToName < ActiveRecord::Migration
  def up
    rename_column :match_results, :result, :name
  end

  def down
  end
end
