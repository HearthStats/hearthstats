class TournDeck < ActiveRecord::Base
  attr_accessible :deck_id, :tournament_id, :tourn_user_id

  belongs_to :tournament
  belongs_to :deck
end
