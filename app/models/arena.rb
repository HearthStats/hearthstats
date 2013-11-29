class Arena < ActiveRecord::Base
  attr_accessible :userclass, :oppclass, :win, :gofirst, :user_id, :arena_run_id
  belongs_to :user

  def self.overall_win_rate(userid)
  	wins = self.where(user_id: userid, win: true).count
  	totgames = self.where(user_id: userid).count
  	winrate = wins.to_f / totgames

  	winrate
  end

  def self.bestuserarena(userid)
		classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    classarenarate = Hash.new
    classes.each_with_index do |c,i|
      totalwins = 0
      totalgames = 0
      totalwins = Arena.where(:userclass => c, :win => true, :user_id => userid ).count
      totalgames = Arena.where(:userclass => c, :user_id => userid ).count
      if totalgames == 0
      	classarenarate[c] = 0
      else
		    classarenarate[c] = ((totalwins.to_f / totalgames)*100).round
		  end
    end
    arenaclass = classarenarate.max_by {|x,y| y}

    arenaclass
  end
end
