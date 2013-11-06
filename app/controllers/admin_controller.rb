class AdminController < ApplicationController
  def index
  end

  def addid
  	constructed = Constructed.all
  	constructed.each do |c|
  		currentdeck = Deck.where(:name => c.deckname, :user_id => c.user_id)[0]
  		if currentdeck.nil?
  			c.deck_id = Deck.where(:name => c.deckname)[0]
  		else
	  		c.deck_id = currentdeck.id
	  	end
	  	c.save
  	end
  	redirect_to root_url, notice: 'SUCCESSSS'
  end
end
