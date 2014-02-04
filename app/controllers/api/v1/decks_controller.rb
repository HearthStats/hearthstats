module Api
	module V1
		class DecksController < ApplicationController
			before_filter :validate_userkey, :get_user_api
			skip_before_filter :get_user_api, :only => :show
			respond_to :json

			def show
		    user = User.where(userkey: params[:userkey])[0]
				begin
			    decks = Deck.where(user_id: user.id, active: true)
			  rescue
			  	api_response = {status: "error", message: "Error getting user's decks"}
			  else
			    api_response = {status: "success", data: decks}
			  end
				render :json => api_response
			end
		end
	end
end