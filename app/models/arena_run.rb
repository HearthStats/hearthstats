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
  	average_win = wins.compact.inject{ |sum, el| sum + el }.to_f / wins.size

  	average_win
  end

  def self.totalGold(userid)
  	arena_games = ArenaRun.where(user_id: userid)
  	goldamount = arena_games.map { |e| e.gold }
  	total_gold = goldamount.inject do |sum, el|
  		sum + el unless el
  	end

  	total_gold
  end

  def self.totalDust(userid)
  	arena_games = ArenaRun.where(user_id: userid)
  	goldamount = arena_games.map { |e| e.dust }
  	total_dust = goldamount.inject do |sum, el|
  		sum + el unless el
  	end

  	total_dust
  end

  def self.classArray(userid)
    classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    class_array = Hash.new
  	classes.each do |c|
  		class_avgwins = ArenaRun.averageWins(c, userid)
  		class_runs = ArenaRun.where( userclass: c, user_id: userid ).count
  		class_winrate = Arena.where( userclass: c, user_id: userid, win: true ).count.to_f / Arena.where( userclass: c, user_id: userid ).count
  		class_coinrate = Arena.where( userclass: c, user_id: userid, win: true, gofirst: true ).count.to_f / Arena.where( userclass: c, user_id: userid, gofirst: true ).count
  		class_nocoinrate = Arena.where( userclass: c, user_id: userid, win: true, gofirst: false ).count.to_f / Arena.where( userclass: c, user_id: userid, gofirst: false ).count

  		class_array[c] = [["Average wins", class_avgwins],
  											["Total runs with class", class_runs],
  											["Class winrate", class_winrate],
  											["Win rate with coin", class_coinrate],
  											["Win rate without coin", class_nocoinrate]]
  	end

  	class_array
  end
end
