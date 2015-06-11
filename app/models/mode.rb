class Mode < ActiveRecord::Base
  attr_accessible :name

  ARENA = 1
  CASUAL = 2
  RANKED = 3
  FRIENDLY = 4

  LIST = {
    1 => 'Arena',
    2 => 'Casual',
    3 => 'Ranked',
    4 => 'Tournament'
  }
  ### ASSOCIATIONS:

  has_many :matches

  def self.all_modes
    @all_modes ||= Mode.all
  end
end
