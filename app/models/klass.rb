class Klass < ActiveRecord::Base
  attr_accessible :name
  belongs_to :deck
  belongs_to :match

end
