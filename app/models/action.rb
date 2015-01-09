class Action < ActiveRecord::Base
  attr_accessible :time, :action, :card, :card_id, :user_id, :match_id
  
  ### ASSOCIATIONS:
  belongs_to :match

  ### CALLBACKS:
  ### CLASS METHODS:
  ### INSTANCE METHODS:
end
