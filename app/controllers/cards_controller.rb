class CardsController < ApplicationController
  def index
    @classes = Klass.order('name ASC');
    @types = Type.order('name ASC');
    @races = Race.order('name ASC');

    @cards = Card

    #filter by card text
    @text_filter = params['text']
    if !@text_filter.blank?
      t = Card.arel_table
      @cards = @cards.where(
        t[:name].matches("%" + @text_filter + "%").
        or(t[:description].matches("%" + @text_filter + "%"))
      )
    end

    # filter by card type
    @type_filter = params['type']
    if !@type_filter.blank?
     @cards = @cards.where('type_name = ?', @type_filter)
    end

    # filter by card class
    @class_filter = params['class']
    if !@class_filter.blank?
     @cards = @cards.where('klass_id = ?', @class_filter)
    elsif @class_filter == "neutral"
        @cards = @cards.where('klass_id  IS NULL')
    end

    #sort field
    @sort_field = "mana"
    sort_request = params['sort']
    if !sort_request.blank? && sort_request.match("attack|name|health|mana")
      @sort_field = sort_request
    end

    # don't show spells if sort by attack or health
    if @sort_field == "attack" || @sort_field == "health"
      @cards = @cards.where("type_name != ?", "Spell")
    end

    # sort order
    @order_filter = params['order']
    if @order_filter.blank? || (@order_filter != "desc" && @order_filter != "asc")
     @order_filter = "asc"
    end
    @cards = @cards.order(@sort_field + ' ' + @order_filter.upcase + ", name ASC")
  end
end
