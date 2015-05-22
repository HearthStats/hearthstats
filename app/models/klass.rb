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

  COLORS = {
    1 => '#FF7D0A',
    2 => '#ABD473',
    3 => '#69CCF0',
    4 => '#F58CBA',
    5 => '#999999',
    6 => '#f1c40f',
    7 => '#0070DE',
    8 => '#9482C9',
    9 => '#C79C6E' 
  }

  ### ASSOCIATIONS:

  has_many :deck
  has_many :matches

  ### VALIDATIONS:

  validates :name, uniqueness: true

  ### CLASS METHODS:

  def self.all_klasses
    @all_klasses ||= Klass.all # this can be cached somewhere
  end

  def self.list
    LIST.values
  end
end
