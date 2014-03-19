class TeamUser < ActiveRecord::Base
  attr_accessible :user_id, :team_id
  belongs_to :team
  belongs_to :user
end
