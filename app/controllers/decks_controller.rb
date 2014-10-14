class DecksController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :public, :public_show]
  caches_action :public_show, expires_in: 1.day

  def index
    @decks = Deck.joins("LEFT OUTER JOIN unique_decks ON decks.unique_deck_id = unique_decks.id").
      order(:created_at).
      where(user_id: current_user.id).
      reverse

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end

  def public
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
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end


  def show
    @deck = Deck.find(params[:id])
    impressionist(@deck)
    gon.cardstring = @deck.cardstring

    if !params[:version].nil?
      cardstring = @deck.deck_versions.select {|d| d.version == params[:version].to_i}[0].try(:cardstring)
      @deck.cardstring = cardstring
    end

    @card_array = @deck.card_array_from_cardstring

    deck_cache_stats = Rails.cache.fetch("deck_stats" + @deck.id.to_s)
    if deck_cache_stats.nil?
      matches = @deck.matches

      # Win rates vs each class
      @deckrate = Array.new
      scope = matches.group(:oppclass_id)
      total = scope.count
      wins = scope.where(result_id: 1).count

      total.each do |klass_id, tot|
        klass_name = Klass::LIST[klass_id]
        if tot== 0
          @deckrate << [0,"#{klass_name}<br/>0 Games"]
        else
          @deckrate << [((wins[klass_id].to_f / tot )*100).round(2), "#{klass_name}<br/>#{tot} Games"]
        end
      end
      # Going first vs 2nd
      @firstrate = get_win_rate(matches.where(coin: false), true)
      @secrate = get_win_rate(matches.where(coin: true), true)

      #calculate deck winrate

      @winrate = matches.count > 0 ? get_win_rate(matches) : 0
      Rails.cache.write("deck_stats" + @deck.id.to_s, [@deckrate,@firstrate,@secrate,@winrate], expires_in: 1.days)
    else
      @deckrate = deck_cache_stats[0]
      @firstrate = deck_cache_stats[1]
      @secrate = deck_cache_stats[2]
      @winrate = deck_cache_stats[3]
    end


    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def public_show
    @deck = Deck.find(params[:id])
    # unique = @deck.unique_deck
    # if unique.nil?
    #   redirect_to deck_path(@deck) and return
    # end
    # impressionist(unique)
    #
    # @card_array = @deck.card_array_from_cardstring
    # @matches    = unique.matches
    #
    # # Win rates vs each class
    # @deckrate = Array.new
    # i = 0
    # Klass.order("name").each do |c|
    #   wins = @matches.where(oppclass_id: c.id, result_id: 1).count
    #   totgames = @matches.where(oppclass_id: c.id).count
    #   if totgames == 0
    #     @deckrate[i] = [0,"#{c.name}<br/>0 Games"]
    #   else
    #     @deckrate[i] = [((wins.to_f / totgames)*100).round(2), "#{c.name}<br/>#{totgames} Games"]
    #   end
    #   i = i + 1
    # end
    #
    # # Going first vs 2nd
    # @firstrate = get_win_rate(@matches.where(coin: false), true)
    # @secrate = get_win_rate(@matches.where(coin: true), true)
    #
    # #calculate deck winrate
    #
    # @winrate = @matches.count > 0 ? get_win_rate(@matches) : 0
    #
    respond_to do |format|
      format.html { redirect_to @deck }
    end
  end

  def new_splash
    @klasses = Klass.all

    respond_to do |format|
      format.html
    end
  end

  def new
    if params[:klass].nil?
      redirect_to new_splash_decks_path, alert: "Please select a class" and return
    end
    gon.cards = Card.where(klass_id: [nil, params[:klass]])
    @deck = Deck.new
    @deck.klass_id = params[:klass]
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
    gon.deck = @deck
    gon.cards = Card.all
    canedit(@deck)
  end

  def merge
    @decks = Deck.find(params["deck_merge"])
  end

  def submit_merge
    master = Deck.find(params[:master])
    slaves = Deck.find(params[:slaves])

    slaves.each do |deck|
      deck.match_deck.each do |match_deck|
        match_deck.update_attribute(:deck_id, master.id)
      end
      deck.update_user_stats!
      deck.destroy
    end
    master.update_user_stats!
    redirect_to decks_path
  end

  def create
    @deck = Deck.new(params[:deck])
    @deck.user_id = current_user.id
    if current_user.guest?
      @deck.is_public = false
    end
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
        format.html { redirect_to @deck, notice: 'Deck was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @deck = Deck.find(params[:id])
    if @deck.is_tourn_deck
      render action: "index" and return
    end
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
        format.html { redirect_to @deck, notice: 'Deck was successfully updated.' }
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
    if version_deck(deck)
      redirect_to edit_deck_path(deck), notice: "Previous deck version saved"
    else
      redirect_to edit_deck_path(deck), alert: "Deck version could not be saved"
    end
  end

  def tags
    response = Deck.tag_counts.map { |tag| {id:tag.name,label:tag.name, value: tag.name} }
    render json: response
  end

  private

  def version_deck(deck)
    last_version = deck.deck_versions.last
    if last_version.nil?
      version = 1
    else
      version = last_version.version.to_i + 1
    end
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
      qty = /^([1-2])/.match(line)[1]
      name = /^[1-2] (.*)/.match(line)[1]
      begin
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
    return 'num_users' unless params[:sort]

    sort = (Deck.column_names + UniqueDeck.column_names).include?(params[:sort]) ? params[:sort] : 'num_users'

    sort =  %w(created_at name).include?(sort) ? "decks.#{sort}" : sort
  end

  def direction
    %w{asc desc}.include?(params[:order]) ? params[:order] : 'desc'
  end
end
