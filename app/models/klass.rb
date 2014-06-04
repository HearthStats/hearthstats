class Klass < ActiveRecord::Base
  attr_accessible :name
  
  ### ASSOCIATIONS:
  
  has_many :deck
  has_many :matches
  
  ### VALIDATIONS:
  
  validates :name, uniqueness: true
  
  ### CLASS METHODS:
  
  def self.list
    ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
  end
end
