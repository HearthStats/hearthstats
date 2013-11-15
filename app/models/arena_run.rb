class ArenaRun < ActiveRecord::Base
  attr_accessible :class, :gold, :dust, :completed, :user_id, :userclass
  has_many :arenas

  after_destroy :delete_all_constructed

  def delete_all_constructed
  	Arena.destroy_all(:arena_run_id => self.id)	
  end
end
