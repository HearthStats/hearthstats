class Constructed < ActiveRecord::Base
  attr_accessible :deckname, :oppclass, :win, :gofirst, :notes, :rank, :deck_id, :user_id
  belongs_to :deck

  def self.overall_win_rate(userid)
  	wins = self.where(user_id: userid, win: true).count
  	totgames = self.where(user_id: userid).count
  	winrate = wins.to_f / totgames

  	winrate
  end
end
