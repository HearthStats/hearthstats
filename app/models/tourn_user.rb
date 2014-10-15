class TournUser < ActiveRecord::Base
  attr_accessible :user_id, :tournament_id

  belongs_to :tournament
  belongs_to :user

  ### INSTANCE METHODS
  def decks_submitted?
    decks = TournDeck.where(tournament_id: self.tournament_id, tourn_user_id: self.id)
    !decks.empty?
  end

  def get_score
    pairs = TournPair.where("tournament_id = ? AND (p1_id = ? OR p2_id = ?)", self.tournament_id, self.id, self.id)
    score = 0
    pairs.each do |pair|
      if pair.winner_id == self.id
        score += 1
      end
    end
    score
  end

end
