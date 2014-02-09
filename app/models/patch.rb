class Patch < ActiveRecord::Base
  attr_accessible :num
  has_many :matches
end
