class Klass < ActiveRecord::Base
  attr_accessible :name
  
  LIST = {
    1 => 'Druid',
    2 => 'Hunter',
    3 => 'Mage',
    4 => 'Paladin',
    5 => 'Priest',
    6 => 'Rogue',
    7 => 'Shaman',
    8 => 'Warlock',
    9 => 'Warrior'
  }
  
  ### ASSOCIATIONS:
  
  has_many :deck
  has_many :matches
  
  ### VALIDATIONS:
  
  validates :name, uniqueness: true
  
  ### CLASS METHODS:
  
  def self.list
    LIST
  end
end
