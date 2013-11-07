class Profile < ActiveRecord::Base
  attr_accessible :bnetid, :name, :private
  belongs_to :users
end
