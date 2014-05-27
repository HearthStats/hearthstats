class Season < ActiveRecord::Base
  attr_accessible :num
  
  ### ASSOCIATIONS:
  
  has_many :matches
end