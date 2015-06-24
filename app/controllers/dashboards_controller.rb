class DashboardsController < ApplicationController
  before_filter :authenticate_user!

  def race
    @matches = Match.where(user_id: current_user.id, klass_id: params[:race])
  end

  def index
    if !current_user.guest? && current_user.profile.name.blank?
      redirect_to edit_profile_path(current_user), alert: 'Please add a username' and return
    end
    if current_user && !current_user.subscription_id.nil?
      redirect_to premium_dashboards_path and return
    end
    dash_cache = Rails.cache.fetch("dash_stats-#{current_user.id}", expires_in: 1.hour) do
      # Get all user's matches from this season
      matches = Match.where(user_id: current_user.id, season_id: current_season).all
      arena_matches = matches.select { |match| match.mode_id == 1 }
      ranked_matches = matches.select { |match| match.mode_id == 3 }
      @arena_wr = get_array_wr(arena_matches, true)
      @con_wr = get_array_wr(ranked_matches, true)
      @recent_entries = matches.sort_by{|m| m.created_at}.last(10).reverse
      @arenawins = Match.winrate_per_day_cumulative(arena_matches, 10)
      @conwins   = Match.winrate_per_day_cumulative(ranked_matches, 10)
      hourly_wr = Match.winrate_by_time(current_user.matches, current_user.profile.time_zone)
      [@arena_wr, @con_wr, @arenawins, @conwins, @recent_entries, hourly_wr]
    end
    @arena_wr = dash_cache[0]
    @con_wr = dash_cache[1]
    @arenawins = dash_cache[2]
    @conwins = dash_cache[3]
    @recent_entries = dash_cache[4]
    gon.hourly_wr = dash_cache[5]
    topdeck_id = Rails.cache.fetch("topdeck-#{current_user.id}", expires_in: 1.day) do
      deck = Deck.bestuserdeck(current_user.id)
      return deck.id if deck
    end

    begin
      @topdeck = Deck.find(topdeck_id)
    rescue
      Rails.cache.delete("topdeck-#{current_user.id}")
      topdeck_id = Rails.cache.fetch("topdeck-#{current_user.id}", expires_in: 1.day) do
        Deck.bestuserdeck(current_user.id)
      end
    end
    @toparena = Match.bestuserarena(current_user.id)
  end

  def premium
    dash_cache = Rails.cache.fetch("prem_dash_stats-#{current_user.id}", expires_in: 1.hour) do
      # Get all user's matches from this season
      matches = Match.where(user_id: current_user.id, season_id: current_season).all
      arena_matches = matches.select { |match| match.mode_id == 1 }
      ranked_matches = matches.select { |match| match.mode_id == 3 }
      @arena_wr = get_array_wr(arena_matches, true)
      @con_wr = get_array_wr(ranked_matches, true)
      hourly_wr = Match.winrate_by_time(current_user.matches, current_user.profile.time_zone)
      [@arena_wr, @con_wr, hourly_wr]
    end
    @arena_wr = dash_cache[0]
    @con_wr = dash_cache[1]
    gon.hourly_wr = dash_cache[3]
    render layout: "no_breadcrumbs"
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

  def prem_dash
    render layout: "prem_dash"
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
