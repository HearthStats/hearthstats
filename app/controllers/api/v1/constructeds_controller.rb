module Api
	module V1
		class ConstructedsController < ApplicationController
			before_filter :get_app_key, :get_user_api
			skip_before_filter :get_user_api, :only => :show
			respond_to :json

			def show
				render :json => "hello"
			end

			def new
				# Required params:
				# :userclass, :deckslot, :oppclass, :win, :gofirst, :rank
				# Optional params:
				# :notes
				arena_run = ArenaRun.where(user_id: @user.id, complete: false).last
				constructed = Constructed.new
				@deck = Deck.where(user_id: @user.id, slot: @req[:slot], active: true)[0]
				# Check if deck exists
				if @deck.nil?
					@deck = create_new_deck
				else
					# Check if correct slot
					if @deck.race != @req[:userclass]
						@deck.active = false
						@deck.slot = nil
						@deck.save

						@deck = create_new_deck
					end
				end

				# Set constructed fields
				constructed.user_id = @user.id
				constructed.deckname = @deck.name
				constructed.deck_id = @deck.id
				constructed.oppclass = @req[:oppclass]
				constructed.win = @req[:win]
				constructed.gofirst = @req[:gofirst]
				constructed.rank = @req[:rank]

				if constructed.save
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
				new_deck.race = @req[:userclass]
				new_deck.name = "Unnamed #{@req[:userclass]}"
				if new_deck.save
					deck = new_deck
				else
	        render json: {status: "fail", message: "New custom deck creation failure."} and return
				end
			end
		end
	end
end