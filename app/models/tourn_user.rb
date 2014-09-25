class TournUser < ActiveRecord::Base
  attr_accessible :user_id, :tournament_id

  belongs_to :tournament
  belongs_to :user

  ### INSTANCE METHODS
  def decks_submitted?
    decks = TournDeck.where(tournament_id: self.tournament_id, tourn_user_id: self.id)
    !decks.empty?
  end

end
