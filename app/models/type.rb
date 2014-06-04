class Type < ActiveRecord::Base
  attr_accessible :name
  
  ### ASSOCITIONS:
  
  has_many :cards
  
end
