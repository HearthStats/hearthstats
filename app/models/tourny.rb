class Tourny < ActiveRecord::Base
  attr_accessible :challonge_id, :prize, :status, :winner_id
  has_many :users
end
