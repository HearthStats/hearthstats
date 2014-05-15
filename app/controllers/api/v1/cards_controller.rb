class Api::V1::CardsController < ApplicationController

  def index
    @cards = Card.all
    render json: { status: "success", data: @cards }
  end

  def show
    @card = Card.find(params[:id])
    render json: { status: "success", data: @card }
  end

end
