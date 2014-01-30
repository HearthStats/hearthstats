class OppnameForArenaAndConstructed < ActiveRecord::Migration
  def up
  	add_column :constructeds, :oppname, :string
  	add_column :constructeds, :ranklvl, :int
  	add_column :constructeds, :legendary, :int

  	add_column :arenas, :oppname, :string
  end

  def down
  end
end
