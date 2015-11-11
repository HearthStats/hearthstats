class DecksController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :public, :public_show]

  def index
    @decks = Deck.joins("LEFT OUTER JOIN unique_decks ON decks.unique_deck_id = unique_decks.id").
      order(:created_at).
      where(user_id: current_user.id).
      reverse
    Deck.archive_unused(current_user)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end

  def search
    params[:items] ||= 20
    params[:sort] ||= "winrate"
    params[:order] ||= "desc"

    @q = Deck.where(is_public: true).
              group(:unique_deck_id).
              includes(:unique_deck, user: :profile).
              ransack(params[:q])
    @q.unique_deck_num_matches_gteq = '30' unless params[:q]
    @q.unique_deck_created_at_gteq = 1.week.ago unless params[:q]

    @decks = @q.result
    @decks = @decks.order("#{sort_by} #{direction}")
    @decks = @decks.paginate(page: params[:page], per_page: params[:items])

    unless current_user.nil?
      unique_deck_ids = @decks.map(&:unique_deck_id)
      @user_decks = current_user.decks.where("unique_deck_id IN (?)", unique_deck_ids)
    end

    respond_to do |format|
      format.html
      format.json { render json: @decks }
    end
  end

  def marketplace
    @prodecks = Deck.where(deck_type_id: 4).last(25)
    @top_decks = Rails.cache.read('top_decks') || []  #[name, author, slug, class_name]
    # Take out for reduction
    # top_adecks = Rails.cache.read('top_adecks') || {}
    # @ar1 = top_adecks.try(:values)[0] || []
    # @ar1_name = top_adecks.try(:keys)[0] || []
    # @ar2 = top_adecks.try(:values)[1] || []
    # @ar2_name = top_adecks.try(:keys)[1] || []
    # @ar3 = top_adecks.try(:values)[2] || []
    # @ar3_name = top_adecks.try(:keys)[2] || []

    render layout: "no_breadcrumbs"
  end


  def show
    begin
      @deck = Deck.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to public_decks_path, alert: "Deck cannot be found" and return
    end

    impressionist(@deck)
    commontator_thread_show(@deck)

    begin
      @notes = JSON.parse(@deck.notes)
      @general = @notes["general"]
      @mulligan = @notes["mulligan"]
      @strategy = @notes["strategy"]
      @matchups = @notes["matchups"]
    rescue TypeError, JSON::ParserError => e
      @notes = @deck.notes
      @general = @notes
    end 

    all_versions = @deck.deck_versions
    if !params[:version].nil?
      deck_version = all_versions.find {|d| d.version == params[:version]}
      @deck.cardstring = deck_version.try(:cardstring)
    end

    @card_array = @deck.card_array_from_cardstring

    deck_cache_stats = Rails.cache.fetch("deck_stats" + @deck.id.to_s + params[:version].to_s, expires_in: 4.hours)
    if deck_cache_stats.nil?
      matches = @deck.matches.all
      if deck_version
        newer_version = deck_version.newer_version
        if newer_version == deck_version
          matches = @deck.matches.
            select{|m| m.created_at >= deck_version.created_at}
        else
          matches = @deck.matches.
            select{|m| m.created_at > deck_version.created_at && m.created_at <= newer_version.created_at}
        end

      end

      # Win rates vs each class
      @deckrate = []
      klass_matches = matches.group_by {|m| m.oppclass_id}
      klass_matches.each do |klass_id, klass_m|
        wins = klass_m.select {|m| m.result_id == 1}.count
        tot = klass_m.count

        wr = (wins.to_f/tot * 100 ).round(2)

        @deckrate << [wr, "#{Klass::LIST[klass_id]}<br/>#{tot} Games", klass_id]
      end

      # Going first vs 2nd
      @firstrate = get_array_wr(matches.select{|m| m.coin == false}, true)
      @secrate = get_array_wr(matches.select{|m| m.coin == true}, true)

      # Win rate by rank

      @rank_wr = @deck.
        rank_wr.
        select {|rank| !rank[0].nil?}.
        map { |rank, wr| [rank.id, wr]}
      #calculate deck winrate
      @winrate = matches.count > 0 ? get_array_wr(matches) : 0
      Rails.cache.write("deck_stats" + @deck.id.to_s + params[:version].to_s,
                        [@deckrate,@firstrate,@secrate,@winrate,@rank_wr],
                        expires_in: 1.days)
    else
      @deckrate = deck_cache_stats[0]
      @firstrate = deck_cache_stats[1]
      @secrate = deck_cache_stats[2]
      @winrate = deck_cache_stats[3]
      @rank_wr = deck_cache_stats[4]
    end

    # Diff between versions
    @diff_hash = {}
    if all_versions.count > 1
      all_versions.each do |version|
        next if version.cardstring.blank?
        version_array = cardstring_to_array(version.cardstring)
        original_array = cardstring_to_array(@deck.cardstring)
        diff_string = calculate_diff(original_array, version_array)
        @diff_hash[version.id] = diff_string
      end
    else
      @diff_hash[all_versions[0]] = []
    end
    gon.cardstring = @deck.cardstring
    gon.rank_wr = @rank_wr

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def public_show
    begin
      @deck = Deck.includes(:unique_deck, :match_decks, :matches).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to public_decks_path, alert: "Deck cannot be found" and return
    end
    if @deck.unique_deck.nil?
      redirect_to deck_path(@deck) and return
    end
    
    begin
      @notes = JSON.parse(@deck.notes)
      @general = @notes["general"]
      @mulligan = @notes["mulligan"]
      @strategy = @notes["strategy"]
      @matchups = @notes["matchups"]
    rescue TypeError, JSON::ParserError => e
      @notes = @deck.notes
      @general = @notes
    end 

    @card_array = @deck.card_array_from_cardstring
    commontator_thread_show(@deck)

    deck_cache_stats = Rails.cache.fetch("public_deck_stats" + @deck.id.to_s)
    if deck_cache_stats.nil?
      unique_deck = @deck.unique_deck
      matches = unique_deck.decks.map(&:matches).flatten

      # Win rates vs each class
      @deckrate = Array.new
      scope = matches.group_by(&:oppclass_id)
      total = {}
      wins = {}
      scope.each do |klass, klass_matches|
        total[klass] = klass_matches.count
        wins[klass] = klass_matches.select {|m| m.result_id == 1}.count
      end
      total = total.reject{|klass_id, tot| tot == nil || klass_id == nil}
      total = total.sort_by{|klass_id, tot| klass_id}

      total.each do |klass_id, tot|
        klass_name = Klass::LIST[klass_id]
        if tot== 0
          @deckrate << [0,"#{klass_name}<br/>0 Games", klass_id]
        else
          @deckrate << [((wins[klass_id].to_f / tot )*100).round(2), "#{klass_name}<br/>#{tot} Games", klass_id]
        end
      end
      # Going first vs 2nd
      first_matches = matches.select{ |match| match.coin == false }
      sec_matches = matches.select{ |match| match.coin == true}
      @firstrate = get_array_wr(first_matches, true)
      @secrate = get_array_wr(sec_matches, true)

      # Win rate by rank

      @rank_wr = @deck.
        rank_wr.
        select {|rank| !rank[0].nil?}.
        map { |rank, wr| [rank.id, wr]}
      #calculate deck winrate
      @winrate = matches.count > 0 ? get_array_wr(matches) : 0
      Rails.cache.write("public_deck_stats" + @deck.id.to_s,
                        [@deckrate,@firstrate,@secrate,@winrate,@rank_wr],
                        expires_in: 1.days)
    else
      @deckrate = deck_cache_stats[0]
      @firstrate = deck_cache_stats[1]
      @secrate = deck_cache_stats[2]
      @winrate = deck_cache_stats[3]
      @rank_wr = deck_cache_stats[4]
    end

    gon.cardstring = @deck.cardstring
    gon.rank_wr = @rank_wr

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new_splash
    @klasses = Klass.all
    @deck = Deck.new(params[:deck])
    respond_to do |format|
      format.html
    end
  end

  def tournament
    @decks = current_user.decks.group(:unique_deck_id)
    @tourney_decks = current_user.decks.where(deck_type_id: 4)
    unless params[:submit_decks].nil?
      params[:submit_decks].each do |deck_id|
        deck = Deck.find(deck_id)
        deck.deck_type_id = 4
        deck.save
      end
    end
    respond_to do |format|
      format.html
    end
  end

  def submit_tourn_decks
  end

  def new
    if params[:klass].nil?
      redirect_to new_splash_decks_path, alert: "Please select a class" and return
    end
    @cards = Card.where(klass_id: [0,nil,params[:klass]], collectible: true)
    @deck = Deck.new
    @deck.klass_id = params[:klass]
    @archtypes = UniqueDeckType.where(verified: true, klass_id: @deck.klass_id)
    @deck.is_public = true
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def copy
    @deck = Deck.find(params[:id])
    user_copy = @deck.get_user_copy(current_user)
    if user_copy.nil?
      user_copy = @deck.copy(current_user)
    end
    redirect_to(edit_deck_path(user_copy))
  end

  def edit
    @deck = Deck.find(params[:id])
    @cards = Card.where(klass_id: [0,nil,@deck.klass_id], collectible: true)
    @archtypes = UniqueDeckType.where(verified: true, klass_id: @deck.klass_id)
    canedit(@deck)
  end

  def canedit(entry)
    if current_user.id != entry.user_id
      redirect_to dashboards_path, alert: 'You are not authorized to edit that.'
    end
    if entry.deck_type_id == 4
      redirect_to tournament_decks_path, alert: 'That is a tournament deck. You cannot edit it'
    end
  end

  def merge
    @decks = Deck.find(params["deck_merge"])
  end

  def submit_merge
    master = Deck.find(params[:master])
    slaves = Deck.find(params[:slaves])

    slaves.each do |deck|
      deck.match_deck.update_all(deck_id: master.id)
      deck.destroy
    end
    master.update_user_stats!
    redirect_to decks_path
  end

  def create
    @deck = Deck.new(params[:deck])
    @deck.deck_type_id = 1
    @deck.user_id = current_user.id
    @deck.is_public = params[:deck]["is_public"] != "on"
    @deck.notes = params[:notes].to_json
    unless params[:deck_text].blank?
      text2deck = text_to_deck(params[:deck_text])
      if !text2deck.errors.empty?
        redirect_to new_deck_path(klass: @deck.klass_id), alert: text2deck.errors and return
      else
        @deck.cardstring = text2deck.cardstring
      end
    end
    respond_to do |format|
      if @deck.save
        @deck.tag_list.add(params[:tags], parse: true)
        @deck.save
        unique_deck = @deck.unique_deck
        if unique_deck && params[:unique_deck_type_id].present?
          unique_deck.unique_deck_type_id = params[:unique_deck_type_id].to_i
          unique_deck.save
        elsif unique_deck && params[:new_archtype].present?
          found = UniqueDeckType.find_by_name(params[:new_archtype])
          if found
            unique_deck.unique_deck_type_id = found.id
          else
            archtype = UniqueDeckType.create(klass_id: @deck.klass_id, name: params[:new_archtype])
            unique_deck.unique_deck_type_id = archtype.id
          end
          unique_deck.save
        elsif unique_deck
          unique_deck.save
        end
        format.html { redirect_to @deck, notice: 'Deck was successfully created.' }
        format.json { render json: @deck }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @deck = Deck.find(params[:id])
    params[:deck]["is_public"] = params[:deck]["is_public"] != "on"
    @deck.notes = params[:notes].to_json
    expire_fragment(@deck)
    @deck.tag_list = params[:tags]
    respond_to do |format|
      if @deck.update_attributes(params[:deck])
        if !params[:deck_text].blank?
          text2deck = text_to_deck(params[:deck_text])
          if !text2deck.errors.empty?
            redirect_to new_deck_path(klass: @deck.klass_id), alert: text2deck.errors and return
          else
            @deck.cardstring = text2deck.cardstring
            @deck.save
          end
        end
        if params["major_version"]
          version_num = @deck.current_version.try(:version).to_i + 1
          version_deck(@deck, version_num)
        elsif params["minor_version"]
          version_num = (@deck.current_version.try(:version).to_f + 0.1).round(1)
          version_deck(@deck, version_num)
        end
        unique_deck = @deck.unique_deck
        if unique_deck && params[:unique_deck_type_id].present?
          unique_deck.unique_deck_type_id = params[:unique_deck_type_id].to_i
          unique_deck.save
        elsif unique_deck && params[:new_archtype].present?
          found = UniqueDeckType.find_by_name(params[:new_archtype])
          if found
            unique_deck.unique_deck_type_id = found.id
          else
            archtype = UniqueDeckType.create(klass_id: @deck.klass_id, name: params[:new_archtype])
            unique_deck.unique_deck_type_id = archtype.id
          end
          unique_deck.save
        end
        format.html { redirect_to @deck, notice: 'Deck was successfully updated.' }
        format.json { render json: @deck }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @deck = Deck.find(params[:id])
    @deck.destroy
    respond_to do |format|
      format.html { redirect_to decks_url }
    end
  end

  def active_decks
    @active_decks = Deck.where(user_id: current_user.id, active: true)
    @my_decks = getMyDecks()
  end

  def delete_active
    deleted_deck = Deck.find(params[:id])
    if current_user.id != deleted_deck.user_id
      return
    end
    slot = deleted_deck.slot
    deleted_deck.deactivate_deck
    moved_decks = current_user.decks.where(active: true).where('slot > ?', slot)
    moved_decks.each do |deck|
      deck.update_attribute(:slot, slot)
      slot += 1
    end

    redirect_to active_decks_decks_path
  end

  def submit_active_decks
    saves = 0
    Deck.where(user_id: current_user.id).update_all(active: nil)
    (1..9).each do |i|
      slot_deck_id = params[i.to_s]
      if slot_deck_id.blank?
        saves += 1
        next
      end
      deck = Deck.find(slot_deck_id)
      deck.slot = i
      deck.active = true

      if deck.save
        saves += 1
      end
    end
    if saves == 9
      redirect_to active_decks_decks_path, notice: 'Active decks successfully updated.'
    else
      redirect_to active_decks_decks_path, alert: 'Cannot Update Active Decks'
    end
  end

  def version
    deck = Deck.find(params[:id])
    canedit(deck)
    if version_deck(deck, params[:version])
      redirect_to deck, notice: "Deck version saved"
    else
      redirect_to deck, alert: "Deck version could not be saved"
    end
  end

  def tags
    response = Deck.tag_counts.map { |tag| {id:tag.name,label:tag.name, value: tag.name} }
    render json: response
  end

  private

  def calculate_diff(original, version)
    diff_arr = []
    original.each do |card_id, count|
      return if original == version
      card = @card_array.select { |card_arr| card_arr[0].id == card_id }
      card = [[Card.find(card_id)]] if card.blank?
      count_in_version = version[card_id]
      count_diff = count.to_i - count_in_version.to_i
      if count_diff > 0
        diff_arr << "-#{count_diff} #{card[0][0].name}"
      elsif count_diff < 0
        diff_arr << "+#{count_diff.abs} #{card[0][0].name}"
      end
      version.delete(card_id)
    end
    version.each do |card_id, count|
      card = @card_array.select { |card_arr| card_arr[0].id == card_id }
      card = [[Card.find(card_id)]] if card.blank?
      diff_arr << "+#{count} #{card[0][0].name}"
    end

    diff_arr.join("<br/>")
  end

  def cardstring_to_array(cardstring)
    return [] if cardstring.nil?
    card_arr = {}
    cardstring.split(",").map do |card_data|
      card_id, count = card_data.split('_').map(&:to_i)
      card_arr[card_id] = count
    end


    card_arr
  end

  def version_deck(deck, version)
    version = DeckVersion.new( deck_id: deck.id, cardstring: deck.cardstring, version: version )
    if version.save
      return true
    else
      return false
    end
  end

  def getMyDecks()
    Deck.where(user_id: current_user.id).order(:klass_id, :name).all
  end

  Text2Deck = Struct.new(:cardstring, :errors)
  def text_to_deck(text)
    text_array = text.split("\r\n")
    card_array = Array.new
    err = Array.new
    text_array.each do |line|
      begin
        qty = /^([1-2])/.match(line)[1]
        name = /^[1-2] (.*)/.match(line)[1]
        card_id = Card.where("lower(name) =?", name.downcase).first.id
      rescue
        err << ("Problem with line '" + line + "'")
        next
      end
      card_array << card_id.to_s + "_" + qty.to_s

    end

    Text2Deck.new(card_array.join(','), err.join('<br>'))
  end

  def sort_by
    sort = (Deck.column_names + UniqueDeck.column_names).include?(params[:sort]) ? params[:sort] : 'num_users'

    sort =  %w(created_at name user_winrate).include?(sort) ? "decks.#{sort}" : "unique_decks.#{sort}"
  end

  def direction
    %w{asc desc}.include?(params[:order]) ? params[:order] : 'desc'
  end
end
