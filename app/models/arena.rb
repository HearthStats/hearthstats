class Arena < ActiveRecord::Base
  attr_accessible :userclass, :oppclass, :win, :gofirst, :user_id, :arena_run_id, :notes, :oppname
  
  ### ASSOCIATIONS:
  
  belongs_to :user
  belongs_to :arena_run
  
  ### CLASS METHODS:
  
  def self.overall_win_rate(userid)
    matches = Match.where(user_id: userid, season_id: Season.last.num, mode_id: 1)
    wins = matches.where(result_id: true).count
    totgames = matches.count
    winrate = wins.to_f / totgames
    
    winrate
  end
  
  def self.bestuserarena(userid)
    # this method does not seem to be called from anywhere
    
    scope  = Arena.where(user_id: userid).group(:userclass)
    played = scope.count
    wins   = scope.where(win: true).count
    
    class_arena_rate = {}
    played.each do |klass, count|
      class_arena_rate[klass] = ((wins[klass].to_f / count.to_f)*100).round if count > 0
    end
    
    return [Klass.first.name, 0] if class_arena_rate.blank?
    class_arena_rate.max_by {|x,y| y}
  end

end
