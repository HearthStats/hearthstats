class FormatCardsTable < ActiveRecord::Migration
  def up
    remove_column :cards, :hearthhead_id
    remove_column :cards, :image_link
  end

  def down
  end
end
