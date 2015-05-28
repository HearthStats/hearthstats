class Api::V3::DecksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_req, except: [:show, :hdt_after]

  respond_to :json

  def show
    begin
      decks = Deck.where(user_id: current_user.id)
    rescue
      api_response = {
        status:  "error",
        message: "Error getting user's decks"
      }
    else
      api_response = {
        status: "success",
        data:   decks
      }
    end
    render json: api_response
  end

  def hdt_create
    card_string = Deck.hdt_parse(@req[:cards])
    deck = Deck.new( name: @req[:name],
                     klass_id: Klass::LIST.invert[@req[:class]],
                     cardstring: card_string,
                     user_id: current_user.id,
                     notes: @req[:notes]
                   )
    if deck.save
      deck.tag_list = @req[:tags]
      deck_info = { deck: deck, deck_versions: deck.deck_versions }
      api_response =  { status: "success", data: deck_info }
    else
      api_response = { status: "error" }
    end

    render json: api_response
  end

  def hdt_after
    req = ActiveSupport::JSON.decode(request.body)
    decks = Deck.where(deck_type_id: [nil,0,1,3]).where{
      (user_id == my{current_user.id}) &
      (created_at >= DateTime.strptime(req["date"], '%s'))
    }
    api_response = []
    decks.each do |deck|
      versions = deck.deck_versions
      deck_versions = versions.map { |m| {
                              :deck_version_id => m.id,
                              :version => m.version,
                              :cards => m.cardstring_to_blizz} }
      api_response << { :deck => deck,
                        :versions => deck_versions,
                        :current_version => deck.current_version.try(:version),
                        :tags => deck.tag_list,
                        :cards => deck.cardstring_to_blizz
      }
    end

    render json: { status: "success", data: api_response }
  end

  def hdt_edit
    deck = Deck.find(@req[:deck_id])
    if deck.user_id == current_user.id
      cardstring = Deck.hdt_parse(@req[:cards])
      deck.cardstring = cardstring
      deck.name = @req[:name]
      deck.tag_list = @req[:tags]
      deck.notes = @req[:notes]
      if deck.save
        deck.deck_versions.last.update_attribute(:cardstring, cardstring) if deck.deck_versions.last
        api_response =  { status: "success", data: deck }
      else
        api_response = { status: "error" }
      end
    else
      api_response = { status: "error", data: "Deck does not belong to user" }
    end

    render json: api_response

  end

  def create_version
    begin
      deck = Deck.find(@req[:deck_id])
    rescue
      api_response = { status: "error", data: "Deck not found" }
      deck = nil
    end
    
    if !deck.nil? && deck.user_id == current_user.id
      cardstring = Deck.hdt_parse(@req[:cards])
      deck_version = DeckVersion.new(deck_id: deck.id, 
                        version: @req[:version], 
                        cardstring: cardstring)
      if deck_version.save
        deck.update_attribute(:cardstring, cardstring)
        api_response =  { status: "success", data: deck_version }
      else
        api_response = { status: "error" }
      end
    else
      api_response = { status: "error", data: "Deck does not belong to user" }
    end

    render json: api_response
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
    if deck.is_public
      render json: {
        status: "success",
        data: {
          deck:       deck,
          deck_array: res_array
        }
      }
    else
      render json: {
        status:  "error",
        message: "Deck is private"
      }
    end
  end

  def activate
    deck = Deck.find(@req[:deck_id])
    if deck.user.id != current_user.id
      render json: {
        status:  "error",
        message: "Deck does not belong to this user."
      }
      return
    end
    deck.active = !deck.active
    deck.save!
    render json: {
      status: "success",
      data:   deck
    }
  end

  def slots

    Deck.where(user_id: current_user.id).each do |deck|
      deck.slot = nil
      deck.active = false
      deck.save!
    end

    deckIds = [@req[:slot_1],@req[:slot_2],@req[:slot_3],@req[:slot_4],@req[:slot_5],@req[:slot_6],@req[:slot_7],@req[:slot_8],@req[:slot_9]]

    errors = Array.new
    (1..9).each do |i|
      error = set_user_deck_slot(current_user, deckIds[i - 1], i)
      if !error.nil?
        errors.push(error)
      end
    end

    if errors.size > 0
      render json: {
        status:  "fail",
        data:    "",
        message: errors.join(" ")
      }
    else
      render json: {
        status:  "success",
        data:    "",
        message: "Deck slots updated"
      }
    end
  end

  def delete
    unless deck_belongs_to_user?(current_user, @req[:deck_id])
      response = {status: "fail", message: "At least one or more of the decks do not belong to the user"}
    else
      Deck.find(@req[:deck_id]).map(&:destroy)
      response = {status: "success", message: "Decks deleted"}
    end
    render json: response
  end

  private

  def deck_belongs_to_user?(user, deck_ids)
    user_deck_ids = user.decks.pluck(:id)


    array_subset?(deck_ids, user_deck_ids)
  end

  def array_subset?(child, parent)
    parent.length - (parent - child).length == child.length
  end

  def set_user_deck_slot(user, deck_id, slot)
    if deck_id.nil?
      return nil
    end
    deck = Deck.where(user_id: current_user.id, id: deck_id)[0]
    if deck.nil?
      return "No deck with ID " + deck_id.to_s + " found for user #" + current_user.id.to_s + "."
    end
    deck.active = true
    deck.slot = slot
    deck.save!
    return nil
  end
end
