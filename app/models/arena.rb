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

end
