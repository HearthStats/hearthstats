class TournPair < ActiveRecord::Base
  attr_accessible :Tournament_id, :p1_id, :p2_id, :pos, :roundof, :winner_id, :winners

  belongs_to :tournament
  has_many :tourn_matches
end
