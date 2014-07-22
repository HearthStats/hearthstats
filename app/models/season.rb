class Season < ActiveRecord::Base
  attr_accessible :num
  
  ### ASSOCIATIONS:
  
  has_many :matches
  
  ### VALIDATIONS:
  
  validates :num, uniqueness: true
  
  ### CLASS METHODS:
  
  def self.current
    Season.last.id
  end
  
end
