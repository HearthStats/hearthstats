class Api::V3::DecksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_req, except: [:index, :show, :after]

  respond_to :json

  def index
    begin
      decks = Deck.where(user_id: current_user.id)
    rescue
      api_response = {
        status:  400,
        message: "Error getting user's decks"
      }
    else
      api_response = {
        status: 200,
        data:   decks
      }
    end
    render json: api_response
  end

  def create
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
      api_response =  { status: 200, data: deck_info }
    else
      api_response = { status: 400 }
    end

    render json: api_response
  end

  def after_date
    req = @req
    decks = Deck.where(deck_type_id: [nil,0,1,3]).where{
      (user_id == my{current_user.id}) &
      (created_at >= DateTime.strptime(req[:date], '%s'))
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

    render json: { status: 200, data: api_response }
  end

  def edit
    deck = Deck.find(@req[:deck_id])
    if deck.user_id == current_user.id
      cardstring = Deck.hdt_parse(@req[:cards])
      deck.cardstring = cardstring
      deck.name = @req[:name]
      deck.tag_list = @req[:tags]
      deck.notes = @req[:notes]
      if deck.save
        deck.deck_versions.last.update_attribute(:cardstring, cardstring) if deck.deck_versions.last
        api_response =  { status: 200, data: deck }
      else
        api_response = { status: 400 }
      end
    else
      api_response = { status: 400, data: "Deck does not belong to user" }
    end

    render json: api_response

  end

  def create_version
    begin
      deck = Deck.find(@req[:deck_id])
    rescue
      api_response = { status: 400, data: "Deck not found" }
      deck = nil
    end
    
    if !deck.nil? && deck.user_id == current_user.id
      cardstring = Deck.hdt_parse(@req[:cards])
      deck_version = DeckVersion.new(deck_id: deck.id, 
                        version: @req[:version], 
                        cardstring: cardstring)
      if deck_version.save
        deck.update_attribute(:cardstring, cardstring)
        api_response =  { status: 200, data: deck_version }
      else
        api_response = { status: 400 }
      end
    else
      api_response = { status: 400, data: "Deck does not belong to user" }
    end

    render json: api_response
  end

  def show
    deck = Deck.find(params[:id])
    render json: {status: 200, data: deck}
  rescue ActiveRecord::RecordNotFound=> e
    render json: {status: 404, message: e.message }
  end

  def multi_destroy
    unless deck_belongs_to_user?(current_user, @req[:deck_id])
      response = {status: 400, message: "At least one or more of the decks do not belong to the user"}
    else
      Deck.find(@req[:deck_id]).map(&:destroy)
      response = {status: 200, message: "Decks deleted"}
    end
    render json: response
  end

  def delete
    unless deck_belongs_to_user?(current_user, @req[:deck_id])
      response = {status: 400, message: "At least one or more of the decks do not belong to the user"}
    else
      Deck.find(@req[:deck_id]).map(&:destroy)
      response = {status: 200, message: "Decks deleted"}
    end
    render json: response
  end

  def destroy
    match = Deck.find(params[:id])
    if match.destroy
      response = {status: 200}
    else
      response = {status: 400}
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
