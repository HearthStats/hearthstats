class FixDeckVersionTable < ActiveRecord::Migration
  def up
    drop_table :deckversions
  end
end
