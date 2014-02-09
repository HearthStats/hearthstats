class CardsController < ApplicationController
  before_filter :authenticate_user!, :except => :show
  # GET /cards
  # GET /cards.json
  def index
    @decks = Deck.where(:user_id => current_user.id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end
end
