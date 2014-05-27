class Klass < ActiveRecord::Base
  attr_accessible :name
  
  ### ASSOCIATIONS:
  
  belongs_to :deck
  belongs_to :match
  
  ### VALIDATIONS:
  
  validates :name, uniqueness: true
end
