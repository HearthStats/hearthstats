class AppSubmittedByAppToMatches < ActiveRecord::Migration
  def up
  	add_column :matches, :appsubmit, :boolean
  end

  def down
  end
end
