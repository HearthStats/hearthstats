class Tournament < ActiveRecord::Base
  attr_accessible :bracket_format, :creator_id, :id, :name, :num_players

  has_many :users, through: :tourn_users
  ### INSTANCE METHODS:

  def initiate_brackets
  end

end
