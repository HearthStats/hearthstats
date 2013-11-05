class Deck < ActiveRecord::Base
  attr_accessible :loses, :name, :wins, :race
  belongs_to :constructed
end
