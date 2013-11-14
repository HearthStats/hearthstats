class ArenaRun < ActiveRecord::Base
  attr_accessible :class, :gold, :dust, :completed, :user_id, :userclass
  has_many :arenas
end
