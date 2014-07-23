class CardsController < ApplicationController
  def index
    # update()
    @classes = Klass.order('name ASC');
    @types = Type.order('name ASC');
    @races = Race.order('name ASC');

    @cards = Card

    #filter by card text
    @text_filter = CGI.parse(request.query_string)['text'].first
    if !@text_filter.nil?
      t = Card.arel_table
      @cards = @cards.where(
        t[:name].matches("%" + @text_filter + "%").
        or(t[:description].matches("%" + @text_filter + "%"))
      )
    end

    # filter by card type
    @type_filter = CGI.parse(request.query_string)['type'].first
    if !@type_filter.nil? && (Float(@type_filter) rescue false)
     @cards = @cards.where('type_id = ?', @type_filter)
    end

    # filter by card race
    @race_filter = CGI.parse(request.query_string)['race'].first
    if !@race_filter.nil? && (Float(@race_filter) rescue false)
     @cards = @cards.where('race_id = ?', @race_filter)
    else
      if @race_filter == "none"
        @cards = @cards.where('race_id  IS NULL')
      end
    end

    # filter by card class
    @class_filter = CGI.parse(request.query_string)['class'].first
    if !@class_filter.nil? && (Float(@class_filter) rescue false)
     @cards = @cards.where('klass_id = ?', @class_filter)
    else
      if @class_filter == "neutral"
        @cards = @cards.where('klass_id  IS NULL')
      end
    end

    #sort field
    @sort_field = "mana"
    sort_request = CGI.parse(request.query_string)['sort'].first
    if !sort_request.nil? && sort_request.match("attack|name|health|mana")
      @sort_field = sort_request
    end

    # don't show spells if sort by attack or health
    if @sort_field == "attack" || @sort_field == "health"
      @cards = @cards.where("type_id != ?", 2)
    end

    # sort order
    @order_filter = CGI.parse(request.query_string)['order'].first
    if @order_filter.nil? || (@order_filter != "desc" && @order_filter != "asc")
     @order_filter = "asc"
    end
    @cards = @cards.order(@sort_field + ' ' + @order_filter.upcase + ", name ASC")



  end

  def update

    # set this to the card source URL
    source = "http://jeromedane.com/hearthstonejson.php"
    require 'net/http'
    @json_result = Net::HTTP.get(URI(source))
    require 'json'
    @hash = JSON.parse @json_result

    @hash.each do |card_data|
      card = Card.where(name: card_data["name"]).first
      if(card == nil)
        card = Card.new()
      end
      card.name = card_data["name"]
      card.description = card_data["description"]
      card.card_set_id = card_data["set_id"]
      card.rarity_id = card_data["rarity_id"]
      card.type_id = card_data["type_id"]
      card.klass_id = card_data["class_id"]
      card.race_id = card_data["race_id"]
      card.mana = card_data["mana"]
      card.health = card_data["health"]
      card.attack = card_data["attack"]
      card.collectible = card_data["collectible"]
      card.save
    end

  end
end
