class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  
  def race
    @matches = Match.where(user_id: current_user.id, klass_id: params[:race])
  end
  
  def index
    if !current_user.guest? && current_user.profile.name.blank?
      redirect_to edit_profile_path(current_user), alert: 'Please add a username' and return
    end
    
    @arenawins = current_user.winrate_per_day(10, 'arena')
    @conwins   = current_user.winrate_per_day(10, 'constructed')
    
    # Get all user's matches from this season
    matches = Match.where(user_id: current_user.id, season_id: current_season)
    arena_matches = matches.where(mode_id: 1)
    @arena_wr = get_win_rate(arena_matches, true)
    con_matches = matches.where(mode_id: 3)
    @con_wr = get_win_rate(con_matches, true)
    
    @recent_entries = matches.last(10).reverse
    @topdeck = Deck.bestuserdeck(current_user.id)
    @toparena = Match.bestuserarena(current_user.id)
    overall = Rails.cache.fetch("global")
    if overall.nil?
      # Determine Constructed Class Win Rates
      conoverallrate = overall_win_rate(3)
      # Determine Arena Class Win Rates
      arenaoverallrate = overall_win_rate(1)
      matches = Match.where(season_id: current_season)
      @global = Hash.new
      @global[:arena] = get_win_rate(matches.where(mode_id: 1))
      @global[:con] = get_win_rate(matches.where(mode_id: 3))
      @global[:coin] = get_win_rate(matches.where(coin: false))
      Rails.cache.write("global", [conoverallrate,arenaoverallrate,@global], expires_in: 1.days)
    else
      conoverallrate = overall[0]
      arenaoverallrate = overall[1]
      @global = overall[2]
    end
    @classconrate = conoverallrate[1]
    @contot = conoverallrate[0]
    @classarenarate = arenaoverallrate[1]
    @arenatot = arenaoverallrate[0]
  end
  
  def fullstats
    
    # Determine Arena Class Win Rates
    classes = Klass.list
    @classwinrate = Hash.new
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = Arena.where(userclass: c, win: true).count + Arena.where(oppclass: c, win: false).count
      totalgames = Arena.where(userclass: c).count + Arena.where(oppclass: c).count
      @classwinrate[c] = (totalwins.to_f / totalgames)
      
    end
    @classwinrate = @classwinrate.sort_by { |name, winsrate| winsrate }.reverse
    
    # Determine Arena Class Win Rates
    classcombos = classes.combination(2).to_a
    @userarenarate = Hash.new
    classcombos.each do |combo|
      totalwins = 0
      totalgames = 0
      totalwins = Arena.where(userclass: combo[0], oppclass: combo[1], win: true).count + Arena.where(userclass: combo[1], oppclass: combo[0], win: false).count
      totalgames = Arena.where(userclass: combo[0], oppclass: combo[1]).count + Arena.where(userclass: combo[1], oppclass: combo[0]).count
      @userarenarate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
    end
    
    # Determine Arena Class Win Rates
    @conrate = Hash.new
    classcombos.each do |combo|
      totalwins = 0
      totalgames = 0
      
      totalwins = Constructed.joins(:deck).where(:oppclass => combo[1], :win => true, 'decks.race' => combo[0]).count
      totalwins = totalwins + Constructed.joins(:deck).where(:oppclass => combo[0], :win => false, 'decks.race' => combo[1]).count
      
      totalgames = Constructed.joins(:deck).where(:oppclass => combo[0], 'decks.race' => combo[1]).count + Constructed.joins(:deck).where(:oppclass => combo[1], 'decks.race' => combo[0]).count
      
      @conrate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
    end
    
    expires_in 4.hour, public: true
  end
  
  
  private
  
  def overall_win_rate(mode)
    data = Array.new
    classrate = Hash.new
    tot = Hash.new
    Klass::LIST.each do |c,name|
      matches = Match.where(season_id: current_season)
      totalwins = 0
      totalgames = 0
      totalwins = matches.where(mode_id: mode, klass_id: c, result_id: 1 ).count + matches.where( mode_id: mode, oppclass_id: c, result_id: 2 ).count
      totalgames = matches.where( mode_id: mode, klass_id: c).count + matches.where( mode_id: mode, oppclass_id: c).count
      classrate[name] = totalgames > 0 ? (totalwins.to_f / totalgames) : 0
      tot[name] = totalgames
    end
    classrate = classrate.sort_by { |name, winsrate| winsrate }.reverse
    data << tot
    data << classrate
    
    data
  end
  
end
