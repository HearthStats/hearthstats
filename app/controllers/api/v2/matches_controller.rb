class Api::V2::MatchesController < ApplicationController
  before_filter :authenticate_user!
	before_filter :get_req

  respond_to :json

  def new

    req = @req
    user = current_user

    errors = Array.new

    # get mode
    mode = Mode.where(:name => req[:mode])[0]
    if mode.nil?
      errors.push("Unknown game mode '" + (req[:mode].nil? ? "[undetected]" : req[:mode]) + "'.")
    end

    # check for deck slot if required
    if !mode.nil? && mode.name != "Arena" && req[:slot].nil?
      errors.push("`slot` missing for " + mode.name + " match.")
    end

    #check for rank if ranked mode
    ranklvl = nil
    if !mode.nil? && mode.name == "Ranked" && !req[:ranklvl].nil?
      ranklvl = Rank.find_by_name(req[:ranklvl])
      if ranklvl.nil?
        errors.push("Unknown rank '" + req[:ranklvl].to_s + "'." + str)
      end
    end

    # get user class
    userclass = Klass.find_by_name(req[:class])
    if userclass.nil?
      errors.push("Unknown user class '" + (req[:class].nil? ? "[undetected]" : req[:class]) + "'.")
    end

    # get opponent class
    oppclass = Klass.find_by_name(req[:oppclass])
    if oppclass.nil?
      errors.push("Unknown opponent class '" + (req[:oppclass].nil? ? "[undetected]" : req[:oppclass]) + "'.")
    end

    # get result
    result = MatchResult.find_by_name(req[:result])
    if result.nil?
      errors.push("Unknown result '" + (req[:result].nil? ? "[undetected]" : req[:result]) + "'.")
    end

    if errors.count > 0
      render json: {status: "fail", message: "MATCH NOT RECORDED. Errors detected: " + errors.join(" ")}
    else

      #create the match
      match = Match.new
      match.user_id = user.id
      match.mode = mode
      match.klass = userclass
      match.oppclass = oppclass
      match.result_id = result.id
      match.coin = req[:coin]
      match.oppname = req[:oppname]
      match.numturns = req[:numturns]
      match.duration = req[:duration]
      match.notes = req[:notes]
      match.appsubmit = true

      message = "New #{mode.name} #{userclass.name} vs #{oppclass.name} match created"

      if match.save

        if mode.name == "Arena"

          # associate the match with an arena run
          arena_run = ArenaRun.where(user_id: user.id, complete: false).last
          if arena_run.nil? || arena_run.klass_id != userclass.id
            if arena_run.nil?
              message = "New #{userclass.name} arena run created"
            end
            arena_run = ArenaRun.new(user_id: user.id, klass_id: userclass.id)
            arena_run.save
            if arena_run.klass_id != userclass.id
              message = "Existing #{arena_run.klass.name} arena run did not match submitted #{userclass.name} match. New #{userclass.name} arena run created."
            end
          end
          # check for completed arena run
          if arena_run.num_losses >= 3 || arena_run.num_wins >= 12
            message = "Existing #{userclass.name} run already had #{arena_run.num_losses >= 3 ? "3 losses" : "12 wins"}. New #{match.klass.name} run created."
            arena_run = ArenaRun.new(user_id: user.id, klass_id: match.klass.id)
            arena_run.save
          end
          MatchRun.new(match_id: match.id, arena_run_id: arena_run.id).save!

        else

          # associate the match with its deck
          deck = Deck.where(user_id: user.id, slot: req[:slot], active: true)[0]
          # Check if deck exists
          if deck.nil?
            deck = create_new_deck(user, req[:slot], userclass)
            message = "No deck set for slot #{req[:slot]}. New #{userclass.name} deck created and assigned to #{req[:slot]}."
          elsif deck.klass_id != userclass.id
            # Check if correct slot
            deck.active = false
            deck.slot = nil
            deck.save
            message = "The '#{deck.name}' deck in slot #{req[:slot]} was #{deck.klass.name}. A new #{userclass.name} deck created and assigned in its place."
            deck = create_new_deck(user, req[:slot], userclass)
          end
          MatchDeck.new(match_id: match.id, deck_id: deck.id).save!
          if !ranklvl.nil?
            MatchRank.new(match_id: match.id, rank_id: ranklvl.id).save!
          end
        end
        render json: {status: "success", message: message,  data: match}
      else
        render json: {status: "fail", message: match.errors.full_messages}
      end
    end
  end
  private

  def create_new_deck(user, slot, klass)
    new_deck = Deck.new
    new_deck.user_id = user.id
    new_deck.active = true
    new_deck.slot = slot
    new_deck.klass = klass
    new_deck.name = "Unnamed #{klass.name}"
    if new_deck.save
      return new_deck
    else
      return nil
    end
  end
end