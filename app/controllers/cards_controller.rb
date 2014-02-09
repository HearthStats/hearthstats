class CardsController < ApplicationController
  def index
    #update()
    @cards = Card.order('name ASC')
  end
  
  def update
    
    # set this to the card source URL
    source = "" 
    require 'net/http'
    @jsonResult = Net::HTTP.get(URI(source))
    require 'json'
    @hash = JSON.parse @jsonResult
    
    @hash.each do |cardData|
      card = Card.find(:first, :conditions => ['hearthhead_id = ?', cardData["hearthhead_id"]])
      if(card == nil)
        card = Card.new()
      end
      card.name = cardData["name"];
      card.description = cardData["description"];
      card.hearthhead_id = cardData["hearthhead_id"];
      card.set_id = cardData["set_id"];
      card.rarity_id = cardData["rarity_id"];
      card.type_id = cardData["type_id"];
      card.klass_id = cardData["class_id"];
      card.race_id = cardData["race_id"];
      card.mana = cardData["mana"];
      card.health = cardData["health"];
      card.attack = cardData["attack"];
      card.collectible = cardData["collectible"];
      card.save()
    end
    
  end
end
