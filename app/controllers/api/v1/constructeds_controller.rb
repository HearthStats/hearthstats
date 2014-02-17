module Api
	module V1
		class ConstructedsController < ApplicationController
			before_filter :validate_userkey, :get_user_api
			skip_before_filter :get_user_api, :only => :show
			respond_to :json

			def show
				render :json => "hello"
			end

			def new
				# Required params:
				# :klass_id, :deckslot, :oppclass_id, :result_id, :coin, :rank_id
				# Optional params:
				# :notes, :numturns, :duration, :oppname
				constructed = Match.new
				@deck = Deck.where(user_id: @user.id, slot: @req[:slot], active: true)[0]
				# Check if deck exists
				if @deck.nil?
					@deck = create_new_deck
       
        elsif	@deck.klass_id != @req[:klass_id]
					# Check if correct slot
          @deck.active = false
          @deck.slot = nil
          @deck.save

          @deck = create_new_deck
				end

				# Set constructed fields
				constructed.user_id = @user.id
        constructed.mode_id = @req[:mode_id]
				constructed.oppclass_id = @req[:oppclass_id]
				constructed.result_id = @req[:result_id]
				constructed.coin = @req[:coin]
				constructed.oppname = @req[:oppname]
        constructed.numturns = @req[:numturns]
        constructed.duration = @req[:duration]
        constructed.notes = @req[:notes]

				if constructed.save
          MatchDeck.new(match_id: constructed.id, deck_id: @deck.id).save!
          MatchRank.new(match_id: constructed.id, rank_id: @req[:rank_id]).save!
	        render json: {status: "success", data: constructed}
	      else
	        render json: {status: "fail", message: constructed.errors.full_messages}
	      end

			end

			private

			def create_new_deck
				new_deck = Deck.new
				new_deck.user_id = @user.id
				new_deck.active = true
				new_deck.slot = @req[:slot]
				new_deck.klass_id= @req[:klass_id]
        new_deck.name = "Unnamed #{Klass.find(@req[:klass_id]).name}"
				if new_deck.save
					deck = new_deck
          
          deck
				else
	        render json: {status: "fail", message: "New custom deck creation failure."} and return
				end
			end
		end
	end
end
