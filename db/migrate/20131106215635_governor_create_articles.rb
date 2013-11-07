class GovernorCreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string      :title, :description
      t.string      :format, :default => 'default'
      t.text        :post
      t.references  :author, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end