class Api::V2::MatchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_req, except: [:query, :hdt_after]

  respond_to :json

  def query
    # Check Params
    params[:mode].nil?

    if params[:deck_id].present?
      result = Match.joins(:deck).where('decks.id' => params[:deck_id], user_id: current_user.id)
    else
      result = Match.where(user_id: current_user.id)
    end
    if params[:mode].present?
      result = result.where(mode_id: params[:mode])
    end
    if params[:result].present?
      result = result.where(result_id: params[:result])
    end
    if params[:klass].present?
      result = result.where(klass_id: params[:klass])
    end
    if params[:oppclass].present?
      result = result.where(oppclass_id: params[:oppclass])
    end
    if params[:coin].present?
      if params[:coin] == 'true'
        coin = true
      else
        coin = false
      end
      result = result.where(coin: coin)
    end
    if params[:season].present?
      if params[:season] == "0"
        result = result.where(season_id: current_season)
      else
        result = result.where(season_id: params[:season])
      end
    end
    if params[:last_id]
      result = result.where('id > ?', params[:last_id].to_i)
    end

    merged_result = result.map { |r| r.attributes.merge(deck_id: r.deck.id)}
    render json: { status: "success", data: merged_result }
  end

  def new

    req = @req
    user = current_user

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
        errors.push("Unknown rank '" + req[:ranklvl].to_s + "'." + str)
      end
    end

    # get user class
    userclass = Klass::LIST.invert[req[:class]]
    if userclass.nil?
      errors.push("Unknown user class '" + (req[:class].nil? ? "[undetected]" : req[:class]) + "'.")
    end

    # get opponent class
    oppclass = Klass::LIST.invert[req[:oppclass]]
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
      match.klass_id = userclass
      match.oppclass_id = oppclass
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

      message = "New #{mode.name} #{req[:class]} vs #{req[:oppclass]} match created"

      if match.save

        if mode.name == "Arena"
          submit_arena_match(current_user, match, userclass)
        else
          submit_ranked_match(match, userclass, ranklvl, legend)
        end

        # Submit log file
        if req[:log]
          s3 = AWS::S3.new
          obj = s3.buckets['hearthstats'].objects["prem-logs/#{match.user_id}/#{match.id}"]
          obj.write(req[:log])
        end

        parser = LogParser.new({
                        :txt_file => req[:log], 
                        :username => user.name,
                        :user_id => user.id,
                        :match_id => match.id
                      })
        parser.delay.parse!

        render json: {status: "success", message: message,  data: match}
      else
        render json: {status: "fail", message: match.errors.full_messages}
      end
    end
  end

  def hdt_new

    req = @req
    user = current_user

    errors = Array.new

    # get mode
    mode = Mode::LIST.invert[req[:mode]]
    if mode.nil?
      errors.push("Unknown game mode '" + (req[:mode].nil? ? "[undetected]" : req[:mode]) + "'.")
    end

    if mode != 1
      # get deck
      begin
        deck = Deck.find(req[:deck_id])
      rescue
        errors.push("Deck could not be found")
      end
    else
      deck = ArenaRun.find(req[:arena_run_id]).deck
    end

    # get user class
    userclass = deck.klass_id if deck
    if userclass.nil?
      errors.push("Unknown user class '" + (req[:class].nil? ? "[undetected]" : req[:class]) + "'.")
    end

    # get opponent class
    oppclass = Klass::LIST.invert[req[:oppclass]]
    if oppclass.nil?
      errors.push("Unknown opponent class '" + (req[:oppclass].nil? ? "[undetected]" : req[:oppclass]) + "'.")
    end

    # get result
    result = Match::RESULTS_LIST.invert[req[:result]]
    if result.nil?
      errors.push("Unknown result '" + (req[:result].nil? ? "[undetected]" : req[:result]) + "'.")
    end
t
    if errors.count > 0
      render json: {status: "fail", message: "MATCH NOT RECORDED. Errors detected: " + errors.join(" ")}
    else

      #create the match
      match = Match.new
      match.user_id = user.id
      match.mode_id = mode
      match.klass_id = userclass
      match.oppclass_id = oppclass
      match.result_id = result
      match.coin = req[:coin]
      match.oppname = req[:oppname]
      match.numturns = req[:numturns]
      match.duration = req[:duration]
      match.notes = req[:notes]
      match.appsubmit = true

      message = "New #{Match::MODES_LIST[mode]} #{req[:class]} vs #{req[:oppclass]} match created"

      if match.save
        if mode == 1
          submit_arena_match(current_user, match, userclass)
        elsif mode == 3
          MatchDeck.create(match_id: match.id,
                           deck_id: deck.id,
                           deck_version_id: req[:deck_version_id].to_i)
          MatchRank.create(match_id: match.id, rank_id: req[:ranklvl].to_i)
          delete_deck_cache!(deck)
        else
          MatchDeck.create(match_id: match.id,
                           deck_id: deck.id,
                           deck_version_id: req[:deck_version_id].to_i)
          delete_deck_cache!(deck)
        end

        # Submit log file
        if req[:log]
          s3 = AWS::S3.new
          obj = s3.buckets['hearthstats'].objects["hdt-logs/#{match.user_id}/#{match.id}"]
          obj.write(req[:log])
        end

        render json: {status: "success", message: message,  data: match}
      else
        render json: {status: "fail", message: match.errors.full_messages}
      end
    end
  end

  def hdt_after
    req = ActiveSupport::JSON.decode(request.body)
    api_response = []
    matches = Match.where{(user_id == my{current_user.id}) & (created_at >= DateTime.strptime(req["date"], '%s'))}
    matches.joins(:match_deck).each do |match|
      api_response << { :deck_id => match.match_deck.deck_id,
                        :deck_version_id => match.match_deck.deck_version_id, 
                        :match => match,
                        :ranklvl => match.rank.try(:id)
      }
    end

    render json: { status: "success", data: api_response}
  end

  def delete
    unless match_belongs_to_user?(current_user, @req[:match_id])
      response = {status: "fail", message: "At least one or more of the matches do not belong to the user"}
    else
      Match.find(@req[:match_id]).map(&:destroy)
      response = {status: "success", message: "Matches deleted"}
    end
    render json: response
  end

  def move
    unless match_belongs_to_user?(current_user, @req[:match_id])
      response = {status: "fail", message: "At least one or more of the matches do not belong to the user"}
    else
      match_decks = Match.find(@req[:match_id]).map(&:match_deck)
      match_decks.map { |match_deck| match_deck.update_attribute(:deck_id, @req[:deck_id].to_i)}
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
    Rails.cache.delete('deck_stats' + deck.id.to_s + deck.current_version.try(:id).to_s)
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

  def submit_arena_match(user, match, userclass)
    # associate the match with an arena run
    arena_run = ArenaRun.where(user_id: user.id, complete: false).last
    if arena_run.nil? || arena_run.klass_id != userclass
      if arena_run.nil?
        message = "New #{Klass::LIST[userclass]} arena run created"
      end
      arena_run = ArenaRun.new(user_id: user.id, klass_id: userclass)
      arena_run.save
      if arena_run.klass_id != userclass
        message = "Existing #{arena_run.klass.name} arena run did not match submitted #{Klass::LIST[userclass]} match. New #{Klass::LIST[userclass]} arena run created."
      end
    end
    # check for completed arena run
    if arena_run.num_losses >= 3 || arena_run.num_wins >= 12
      arena_run.update_attribute(:complete, true)
      message = "Existing #{Klass::LIST[userclass]} run already had #{arena_run.num_losses >= 3 ? "3 losses" : "12 wins"}. New #{match.klass.name} run created."
      arena_run = ArenaRun.new(user_id: user.id, klass_id: match.klass.id)
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
      message = "No deck set for slot #{@req[:slot]}. New #{Klass::LIST[userclass]} deck created and assigned to #{@req[:slot]}."
    end
    MatchDeck.create(match_id: match.id, 
                     deck_id: deck.id,
                     deck_version_id: deck.current_version.try(:id)
                    )
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
