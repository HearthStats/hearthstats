class Constructed < ActiveRecord::Base
  attr_accessible :deckname, :oppclass, :win, :gofirst,
  								:notes, :rank, :deck_id, :user_id, :oppname, :ranklvl, :legendary
  belongs_to :deck

  def self.overall_win_rate(userid)
  	wins = Match.where(user_id: userid, result_id: 1).count
  	totgames = Match.where(user_id: userid).count
  	winrate = wins.to_f / totgames

  	winrate
  end
end
