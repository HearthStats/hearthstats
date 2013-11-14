class Deck < ActiveRecord::Base
  attr_accessible :loses, :name, :wins, :race, :decklink
  has_many :constructed

  after_destroy :delete_all_constructed

  def delete_all_constructed
  	Constructed.destroy_all(:deck_id => self.id)	
  end
end
