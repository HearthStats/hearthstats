class TournUser < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :tournaments
  belongs_to :users
end
