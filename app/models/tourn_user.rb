class TournUser < ActiveRecord::Base
  attr_accessible :user_id, :tournament_id

  belongs_to :tournament
  belongs_to :user
end
