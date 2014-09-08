class Mode < ActiveRecord::Base
  attr_accessible :name

  ### ASSOCIATIONS:

  has_many :matches

  def self.all_modes
    @all_modes ||= Mode.all
  end
end
