class AddHearthheadIdToCards < ActiveRecord::Migration
  def change
    add_column :cards, :hearthhead_id, :integer
  end
end
