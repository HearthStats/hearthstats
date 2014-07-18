class DecksController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :public, :public_show]
  caches_action :public_show, expires_in: 1.day
  
  def index
    @decks = Deck.joins("LEFT OUTER JOIN unique_decks ON decks.unique_deck_id = unique_decks.id").where(user_id: current_user.id)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @decks }
    end
  end

  def public
    params[:items] ||= 20
    
    @q = Deck.where(is_public: true).
              group(:unique_deck_id).
              joins(:unique_deck).
              includes(:unique_deck, user: :profile).
              ransack(params[:q])
              
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

    unless params[:version].nil?
      cardstring = @deck.deck_versions.select {|d| d.version == params[:version].to_i}[0].try(:cardstring)
      @deck.cardstring = cardstring
    end

    @card_array = @deck.card_array_from_cardstring
    
    deck_cache_stats = Rails.cache.fetch("deck_stats" + @deck.id.to_s)
    if deck_cache_stats.nil?
      matches = @deck.matches
      
      # Win rates vs each class
      @deckrate = Array.new

      Klass.order("name").each_with_index do |c, i|
        wins = matches.where(oppclass_id: c.id, result_id: 1).count
        totgames = matches.where(oppclass_id: c.id).count
        if totgames == 0
          @deckrate[i] = [0,"#{c.name}<br/>0 Games"]
        else
          @deckrate[i] = [((wins.to_f / totgames)*100).round(2), "#{c.name}<br/>#{totgames} Games"]
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
    unique = @deck.unique_deck
    if unique.nil?
      redirect_to deck_path(@deck) and return
    end
    impressionist(unique)
    
    @card_array = @deck.card_array_from_cardstring
    @matches    = unique.matches
    
    # Win rates vs each class
    @deckrate = Array.new
    i = 0
    Klass.order("name").each do |c|
      wins = @matches.where(oppclass_id: c.id, result_id: 1).count
      totgames = @matches.where(oppclass_id: c.id).count
      if totgames == 0
        @deckrate[i] = [0,"#{c.name}<br/>0 Games"]
      else
        @deckrate[i] = [((wins.to_f / totgames)*100).round(2), "#{c.name}<br/>#{totgames} Games"]
      end
      i = i + 1
    end
    
    # Going first vs 2nd
    @firstrate = get_win_rate(@matches.where(coin: false), true)
    @secrate = get_win_rate(@matches.where(coin: true), true)
    
    #calculate deck winrate
    
    @winrate = @matches.count > 0 ? get_win_rate(@matches) : 0
    
    respond_to do |format|
      format.html # show.html.erb
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

  def create
    @deck = Deck.new(params[:deck])
    @deck.user_id = current_user.id
    if current_user.guest?
      @deck.is_public = false
    end
    unless params[:deck_text].blank?
      begin
        @deck.cardstring = text_to_deck(params[:deck_text])
      rescue
        redirect_to new_deck_path, alert: 'Deck list process error' and return
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
    @deck.constructeds.update_all(deckname: params[:deck]['name'])
    expire_fragment(@deck)
    respond_to do |format|
      if @deck.update_attributes(params[:deck])
        @deck.tag_list = params[:tags]
        @deck.save
        unless params[:deck_text].blank?
          begin
            @deck.cardstring = text_to_deck(params[:deck_text])
            @deck.save!
          rescue
            redirect_to new_deck_path, alert: 'Deck list process error' and return
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
  
  def submit_active_decks
    saves = 0
    Deck.where(user_id: current_user.id).update_all(active: nil)
    (1..9).each do |i|
      if params[i.to_s].blank?
        saves += 1
        next
      end
      deck = Deck.where(user_id: current_user.id, name: params[i.to_s])[0]
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
  
  def text_to_deck(text)
    text_array = text.split("\r\n")
    card_array = Array.new
    text_array.each do |line|
      qty = /^([1-2])/.match(line)[1]
      name = /^[1-2] (.*)/.match(line)[1]
      card_id = Card.where("lower(name) =?", name.downcase).first.id
      card_array << card_id.to_s + "_" + qty.to_s
    end
    
    return card_array.join(',')
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
