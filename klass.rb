class Klass < ActiveRecord::Base
  attr_accessible :name
  has_many :matches
  has_many :decks
end
