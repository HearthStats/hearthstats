class Constructed < ActiveRecord::Base
  attr_accessible :deckname, :oppclass, :win, :gofirst
  has_one :deck
end
