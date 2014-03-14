class Subscription< ActiveRecord::Base
  attr_accessible :name, :cost
  has_many :users
end
