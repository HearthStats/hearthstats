class TournDeck < ActiveRecord::Base
  attr_accessible :deck_id, :tournament_id, :tournuser_id

  belongs_to :tournament
end
