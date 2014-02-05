class Klass < ActiveRecord::Base
  attr_accessible :name
  has_many :matches
  belongs_to :deck
end
