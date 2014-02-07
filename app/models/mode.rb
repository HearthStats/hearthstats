class Mode < ActiveRecord::Base
  attr_accessible :name
  has_many :matches
end
