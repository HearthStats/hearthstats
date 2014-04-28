class Constructed < ActiveRecord::Base
  attr_accessible :deckname, :oppclass, :win, :gofirst,
  								:notes, :rank, :deck_id, :user_id, :oppname, :ranklvl, :legendary
  belongs_to :deck

  def self.overall_win_rate(userid)
  	matches = Match.where(user_id: userid, season_id: Season.last.num, mode_id: 3)
  	wins = matches.where(result_id: true).count
  	totgames = matches.count
  	winrate = wins.to_f / totgames

  	winrate
  end
end
