class Constructed < ActiveRecord::Base
  attr_accessible :deckname, :oppclass, :win, :gofirst
  belongs_to :deck
end
