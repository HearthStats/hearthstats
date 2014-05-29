class Api::V1::DecksController < ApplicationController
	before_filter :validate_userkey, :get_user_api
	skip_before_filter :get_user_api, :only => :show
	skip_before_filter :get_user_api, :only => :find
	skip_before_filter :validate_userkey, :only => :find

	respond_to :json

	def show
    user = User.where(userkey: params[:userkey])[0]
		begin
	    decks = Deck.where(user_id: user.id)
	  rescue
	  	api_response = {status: "error", message: "Error getting user's decks"}
	  else
	    api_response = {status: "success", data: decks}
	  end
		render :json => api_response
	end

	def find
		deck = Deck.find(params[:deck_id])
		card_array = deck.cardstring.split(",")
		res_array = Array.new
		card_array.each do |card|
			card_count = /_(\d*)/.match(card)[1]
			card_id = /(\d*)_/.match(card)[1]
			card = Card.find(card_id)
			card_name = card.name
			card_mana = card.mana
			res_array << [card_name, card_count, card_mana]
		end

		# html = String.new
		# html << "<div class='decklist'>"
		# card_array.each do |card|
			# card_id = /(\d*)_/.match(card)[1]
			# Card.find()
			# card_count = /_(\d*)/.match(card)[1]
		# 	html << "<div class='cardWrapper #{card_count}'>"
		# 	html << "<div class='mana'>"
		# 	html << "</div>"
		# 	html << "<div class='name'>"
		# 	html << "</div>"
		# 	html << "<div class='qty'>"
		# 	html << "</div>"
		# 	html << "<img src='https://s3-us-west-2.amazonaws.com/hearthstats/cards/#{}.png'>"
		# 	html << "<div class='frame'>"
		# 	html << "</div>"
		# 	html << "</div>"

		# end
		# html << "</div>"

		if deck.is_public
			render :json => {status: "success", data: {deck: deck, deck_array: res_array}}
		else
			render :json => {status: "error", message: "Deck is private"}
		end
	end

  def activate
    deck = Deck.find(@req[:deck_id])
    if deck.user.id != @user.id
      render json: {status: "error", message: "Deck does not belong to this user."} and return
    end
    deck.active = !deck.active
    deck.save!
    render json: {status: "success", data: deck}
  end

  def slots
    user = User.where(userkey: params[:userkey])[0]

    Deck.where(:user_id => user.id).update_all(:slot => nil, :active => false)

    deckIds = [@req[:slot_1],@req[:slot_2],@req[:slot_3],@req[:slot_4],@req[:slot_5],@req[:slot_6],@req[:slot_7],@req[:slot_8],@req[:slot_9]]

    errors = Array.new
    (1..9).each do |i|
      error = set_user_deck_slot(user, deckIds[i - 1], i)
      if !error.nil?
        errors.push(error)
      end
    end

    if errors.size > 0
      render json: {status: "fail", data: "", message: errors.join(" ")}
    else
      render json: {status: "success", data: "", message: "Deck slots updated"}
    end
  end

  private

  def set_user_deck_slot(user, deck_id, slot)
    if deck_id.nil?
      return nil
    end
    deck = Deck.where(:user_id => user.id, :id => deck_id)[0]
    if deck.nil?
      return "No deck with ID " + deck_id.to_s + " found for user #" + user.id.to_s + "."
    end
    deck.active = true
    deck.slot = slot
    deck.save!
    return nil
  end
end
