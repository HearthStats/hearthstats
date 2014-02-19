module Api
	module V1
		class MatchesController < ApplicationController
      before_filter :validate_userkey, :get_user_api
      respond_to :json

      def new

        if @req[:mode_id] == 1
          arena_run = ArenaRun.where(user_id: @user.id, complete: false).last
          if arena_run.nil?
            arena_run = ArenaRun.new(user_id: @user.id, klass_id: @req[:klass_id])
            arena_run.save
          end
          match = Match.new(@req)
          match.user_id = @user.id
          match.appsubmit = true
          if match.save!
            MatchRun.new(match_id: match.id, arena_run_id: arena_run.id).save!
            render json: {status: "success", data: match}
          else
            render json: {status: "fail", message: match.errors.full_messages}
          end
	
        else
          @deck = Deck.where(user_id: @user.id, slot: @req[:slot], active: true)[0]
          # Check if deck exists
          if @deck.nil?
            @deck = create_new_deck
            message = "No deck set, new deck created"
        
          elsif	@deck.klass_id != @req[:klass_id]
            # Check if correct slot
            @deck.active = false
            @deck.slot = nil
            @deck.save

            @deck = create_new_deck

            message = "Deck in slot #{@req[:slot]} has the incorrect class, new deck created"
          end

          match = Match.new
          # Set constructed fields
          match.user_id = @user.id
          match.mode_id = @req[:mode_id]
          match.oppclass_id = @req[:oppclass_id]
          match.result_id = @req[:result_id]
          match.coin = @req[:coin]
          match.oppname = @req[:oppname]
          match.numturns = @req[:numturns]
          match.duration = @req[:duration]
          match.notes = @req[:notes]
          match.appsubmit = true

          if match.save
            MatchDeck.new(match_id: match.id, deck_id: @deck.id).save!
            MatchRank.new(match_id: match.id, rank_id: @req[:rank_id]).save!
            render json: {status: "success", message: message,  data: match}
          else
            render json: {status: "fail", message: match.errors.full_messages}
          end
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
