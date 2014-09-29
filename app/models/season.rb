class Season < ActiveRecord::Base
  attr_accessible :num

  SEASON_BEGINNING = DateTime.strptime("1383264000", '%s')
  ### ASSOCIATIONS:

  has_many :matches

  ### VALIDATIONS:

  validates :num, uniqueness: true

  ### CLASS METHODS:

  def self.current
    Season.last.id
  end

  def begin
    SEASON_BEGINNING + id.months
  end

  def end
    SEASON_BEGINNING + (id+1).months
  end

end
