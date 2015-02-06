class Api::V1::CardsController < ApplicationController
  # before_filter :validate_userkey

  def index
    @cards = Card.where("rarity_id is NOT NULL")
    response = @cards.map {|card| 
      card_j = card.as_json
      card_j["type_id"] = Card::TYPES.invert[card.type_name]

      card_j
    }
    render json: { status: "success", data: response }
  end

  def show
    @card = Card.find(params[:id])
    render json: { status: "success", data: @card }
  end

end
