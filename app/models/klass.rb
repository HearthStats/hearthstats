class Klass < ActiveRecord::Base
  attr_accessible :name
  
  LIST = { 
    1 => 'Druid',
    2 => 'Priest',
    3 => 'Mage',
    4 => 'Warlock',
    5 => 'Warrior',
    6 => 'Paladin',
    7 => 'Shaman',
    8 => 'Hunter',
    9 => 'Rogue'
  }
  
  ### ASSOCIATIONS:
  
  has_many :deck
  has_many :matches
  
  ### VALIDATIONS:
  
  validates :name, uniqueness: true
  
  ### CLASS METHODS:
  
  def self.list
    LIST.values
  end
end
