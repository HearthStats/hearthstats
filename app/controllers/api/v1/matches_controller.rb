class Api::V1::MatchesController < ApplicationController
  before_filter :validate_userkey, :get_user_api
  respond_to :json

  def new

    req = @req
    user = @user

    errors = Array.new

    # get mode
    mode = Mode.where(name: req[:mode])[0]
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
      ranklvl = req[:ranklvl]
      legend = req[:legend] if !req[:legend].nil?
      if ranklvl.nil?
        errors.push("Unknown rank '" + req[:ranklvl].to_s + "'.")
      end
    end

    # get user class
    userclass = Klass.where(name: req[:class])[0]
    if userclass.nil?
      errors.push("Unknown user class '" + (req[:class].nil? ? "[undetected]" : req[:class]) + "'.")
    end

    # get opponent class
    oppclass = Klass.where(name: req[:oppclass])[0]
    if oppclass.nil?
      errors.push("Unknown opponent class '" + (req[:oppclass].nil? ? "[undetected]" : req[:oppclass]) + "'.")
    end

    # get result
    result = Match::RESULTS_LIST.invert[req[:result]]
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
      match.result_id = result
      match.coin = req[:coin]
      match.oppname = req[:oppname]
      match.numturns = req[:numturns]
      match.duration = req[:duration]
      match.notes = req[:notes]
      match.appsubmit = true
      match.opp_archtype_id = UniqueDeckType.find_from_log(
        {:user => req[:opp], 
         :log => req[:log],
         :klass_id => oppclass}
      )

      message = "New #{mode.name} #{userclass.name} vs #{oppclass.name} match created"

      if match.save

        if mode.name == "Arena"
          submit_arena_match(match, userclass)
        else
          submit_ranked_match(match, userclass, ranklvl, legend)
        end

        # Submit log file
        if req[:log]
          s3 = AWS::S3.new
          obj = s3.buckets['hearthstats'].objects["prem-logs/#{match.user_id}/#{match.id}"]
          obj.write(req[:log])
        end

        # parser = LogParser.new({
        #                 :txt_file => req[:log], 
        #                 :username => user.name,
        #                 :user_id => user.id,
        #                 :match_id => match.id
        #               })

        render json: {status: "success", message: message,  data: match}
      else
        render json: {status: "fail", message: match.errors.full_messages}
      end
    end
  end

  def delete
    unless match_belongs_to_user(@user, @req[:match_id])
      response = {status: "fail", message: "At least one or more of the matches do not belong to the user"}
    else
      Match.find(@req[:match_id]).map(&:destroy)
      response = {status: "success", message: "Matches deleted"}
    end
    render json: response
  end

  private

  def match_belongs_to_user?(user, match_ids)
    user_match_ids = user.matches.pluck(:id)


    array_subset?(match_ids, user_match_ids)
  end

  def array_subset?(child, parent)
    parent.length - (parent - child).length == child.length
  end

  def delete_deck_cache!(deck)
    Rails.cache.delete('deck_stats' + deck.id.to_s)
  end

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

  def submit_arena_match(match, userclass)
    # associate the match with an arena run
    arena_run = ArenaRun.where(user_id: @user.id, complete: false).last
    if arena_run.nil? || arena_run.klass_id != userclass.id
      if arena_run.nil?
        message = "New #{userclass.name} arena run created"
      end
      arena_run = ArenaRun.new(user_id: @user.id, klass_id: userclass.id)
      arena_run.save
      if arena_run.klass_id != userclass.id
        message = "Existing #{arena_run.klass.name} arena run did not match submitted #{userclass.name} match. New #{userclass.name} arena run created."
      end
    end
    # check for completed arena run
    if arena_run.num_losses >= 3 || arena_run.num_wins >= 12
      message = "Existing #{userclass.name} run already had #{arena_run.num_losses >= 3 ? "3 losses" : "12 wins"}. New #{match.klass.name} run created."
      arena_run = ArenaRun.new(user_id: @user.id, klass_id: match.klass.id)
      arena_run.save
    end
    MatchRun.new(match_id: match.id, arena_run_id: arena_run.id).save!
  end

  def submit_ranked_match(match, userclass, ranklvl, legend)
    # associate the match with its deck
    deck = Deck.where(user_id: @user.id, slot: @req[:slot], active: true)[0]
    # Check if deck exists
    if deck.nil?
      deck = create_new_deck(@user, @req[:slot], userclass)
      message = "No deck set for slot #{@req[:slot]}. New #{userclass.name} deck created and assigned to #{@req[:slot]}."
    end
    MatchDeck.new(match_id: match.id, 
                  deck_id: deck.id,
                  deck_version_id: deck.current_version.try(:id)
                 ).save!
    delete_deck_cache!(deck)
    if !ranklvl.nil?
      if legend
        MatchRank.new(match_id: match.id, rank_id: ranklvl, legendary: legend).save!
      else
        MatchRank.new(match_id: match.id, rank_id: ranklvl).save!
      end
    end
  end
end
