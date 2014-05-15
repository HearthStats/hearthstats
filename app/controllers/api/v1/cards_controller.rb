class Api::V1::CardsController < ApplicationController

  def index
    @cards = Card.all
    respond_to do |format|
      format.json { render json: @cards }
    end
  end

  def show
    @card = Card.find(params[:id])
    respond_to do |format|
      format.json { render json: @card }
    end
  end

end
