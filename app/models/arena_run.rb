class ArenaRun < ActiveRecord::Base
  attr_accessible :class, :gold, :dust, :completed, :user_id, :userclass, :notes
  has_many :arenas

  after_destroy :delete_all_arena

  def delete_all_arena
  	Arena.destroy_all(:arena_run_id => self.id)
  end

  def self.averageWins(race, userid)
  	arena_games = ArenaRun.where(user_id: userid, :userclass => race)
  	wins = arena_games.map { |e| e.arenas.where(win:true).count }
  	average_win = wins.inject{ |sum, el| sum + el }.to_f / wins.size

  	average_win
  end
end
