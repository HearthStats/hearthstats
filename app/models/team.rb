class Team < ActiveRecord::Base
  attr_accessible :name
  has_many :team_users
  has_many :users, through: :team_users
end
