class Deck < ActiveRecord::Base
  attr_accessible :loses, :name, :wins, :race, :decklink
  has_many :constructed
end
