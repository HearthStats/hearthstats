class Constructed < ActiveRecord::Base
  attr_accessible :deckname, :oppclass, :win, :gofirst,
                  :notes, :rank, :deck_id, :user_id, :oppname, :ranklvl, :legendary

  ### ASSOCIATIONS:

  belongs_to :deck

  ### CLASS METHODS:

  def self.overall_win_rate(userid)
    # returns a winrate percentage if the user has played any Constructed games.
    # otherwise returns "N/A"
    matches = Match.where(user_id: userid, season_id: Season.last.num, mode_id: 3)
    wins = matches.where(result_id: true).count
    totgames = matches.count

    # let's try not to divide by zero  
    return "N/A" if totgames == 0

    winrate = wins.to_f / totgames
    winrate = number_to_percentage(winrate * 100, precision: 2)

    winrate

  end
end
