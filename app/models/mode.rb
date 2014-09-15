class Mode < ActiveRecord::Base
  attr_accessible :name

  ARENA = 1
  CASUAL = 2
  RANKED = 3

  ### ASSOCIATIONS:

  has_many :matches

  def self.all_modes
    @all_modes ||= Mode.all
  end
end
