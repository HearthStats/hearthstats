class Season < ActiveRecord::Base
  attr_accessible :num
  
  ### ASSOCIATIONS:
  
  has_many :matches
  
  ### VALIDATIONS:
  
  validates :num, uniqueness: true
end