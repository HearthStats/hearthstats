class CardsController < ApplicationController
  def index
    # update()
    @classes = Klass.order('name ASC');
    @types = Type.order('name ASC');
    @races = Race.order('name ASC');

    @cards = Card

    #filter by card text
    @textFilter = CGI.parse(request.query_string)['text'].first
    if !@textFilter.nil?
      t = Card.arel_table
      @cards = @cards.where(
        t[:name].matches("%" + @textFilter + "%").
        or(t[:description].matches("%" + @textFilter + "%"))
      )
    end

    # filter by card type
    @typeFilter = CGI.parse(request.query_string)['type'].first
    if !@typeFilter.nil? && (Float(@typeFilter) rescue false)
     @cards = @cards.where('type_id = ?', @typeFilter)
    end

    # filter by card race
    @raceFilter = CGI.parse(request.query_string)['race'].first
    if !@raceFilter.nil? && (Float(@raceFilter) rescue false)
     @cards = @cards.where('race_id = ?', @raceFilter)
    else
      if @raceFilter == "none"
        @cards = @cards.where('race_id  IS NULL')
      end
    end

    # filter by card class
    @classFilter = CGI.parse(request.query_string)['class'].first
    if !@classFilter.nil? && (Float(@classFilter) rescue false)
     @cards = @cards.where('klass_id = ?', @classFilter)
    else
      if @classFilter == "neutral"
        @cards = @cards.where('klass_id  IS NULL')
      end
    end

    #sort field
    @sortField = "mana"
    sortRequest = CGI.parse(request.query_string)['sort'].first
    if !sortRequest.nil? && sortRequest.match("attack|name|health|mana")
      @sortField = sortRequest
    end

    # don't show spells if sort by attack or health
    if @sortField == "attack" || @sortField == "health"
      @cards = @cards.where("type_id != ?", 2)
    end

    # sort order
    @orderFilter = CGI.parse(request.query_string)['order'].first
    if @orderFilter.nil? || (@orderFilter != "desc" && @orderFilter != "asc")
     @orderFilter = "asc"
    end
    @cards = @cards.order(@sortField + ' ' + @orderFilter.upcase + ", name ASC")



  end

  def update

    # set this to the card source URL
    source = ""
    require 'net/http'
    @jsonResult = Net::HTTP.get(URI(source))
    require 'json'
    @hash = JSON.parse @jsonResult

    @hash.each do |cardData|
      card = Card.find(:first, conditions: ['hearthhead_id = ?', cardData["hearthhead_id"]])
      if(card == nil)
        card = Card.new()
      end
      card.name = cardData["name"];
      card.description = cardData["description"];
      card.hearthhead_id = cardData["hearthhead_id"];
      card.card_set_id = cardData["set_id"];
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
