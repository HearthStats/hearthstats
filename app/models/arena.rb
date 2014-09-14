class Arena < ActiveRecord::Base
  attr_accessible :userclass, :oppclass, :win, :gofirst, :user_id, :arena_run_id, :notes, :oppname

  ### ASSOCIATIONS:

  belongs_to :user
  belongs_to :arena_run

  ### CLASS METHODS:

  def self.overall_win_rate(userid)
    # returns a winrate percentage if the user has played any Arena games.
    # otherwise returns "N/A"
    
    matches = Match.where(user_id: userid, season_id: Season.last.num, mode_id: 1)
    wins = matches.where(result_id: true).count
    totgames = matches.count

    # let's try not to divide by zero  
    return "N/A" if totgames == 0

    winrate = wins.to_f / totgames
    winrate = number_to_percentage(winrate * 100, precision: 2)

    winrate

  end

end
