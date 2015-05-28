class Api::V3::DeckVersionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_req, except: [:show, :hdt_after]

  respond_to :json

  def hdt_after
    req = ActiveSupport::JSON.decode(request.body)
    deck_versions = Deck.where(deck_type_id: [nil, 1]).where{
      (user_id == my{current_user.id}) & 
      (created_at >= DateTime.strptime(req["date"], '%s'))
    }
    api_response = []
    deck_versions.each do |deck|
      api_response << { :deck => deck,
                        :cards => deck.cardstring_to_blizz
      }
    end

    render json: { status: "success", data: api_response }
  end
end
