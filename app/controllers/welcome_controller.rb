class WelcomeController < ApplicationController
  def index

    # Global Stats
    @arena_top = Rails.cache.read('wel#arena_top') || []
    @con_top = Rails.cache.read('wel#con_top') || []
    @rank_class = Rails.cache.read('wel#rank_class') || []

    # Decklists
    @recentdecks = Rails.cache.fetch('recent_decks', expires_in: 2.hours) do
      Deck.where(is_public: true).
        includes(:unique_deck).
        includes(:user).
        last(7)
    end
    @topdecks = Rails.cache.fetch('wel#top_decks', expires_in: 2.hours) do
      Deck.where(is_public: true).
        where('decks.created_at >= ?', 1.week.ago).
        group(:unique_deck_id).
        joins(:unique_deck).
        joins(:user).
        where("unique_decks.num_matches >= ?", 30).
        order('unique_decks.winrate DESC').
        first(7).
        to_a
    end
    # Get Class Use % by Rank


    # Streams
    # @featured_streams = Stream.get_featured_streamers
    # @top_streams = get_top_streamers.first(6)

    flash[:notice] = "Welcome back #{current_user.name}" if current_user

    render layout: false
  end

  def select_klass
    @klass = params[:klass_id]
    respond_to do |format|
      format.js
    end
  end

  def newsletter_sub
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Newsletter Subscribed" }
    end
    begin
      c = Cindy.new "http://news.hearthstats.net", "bM0U7Pvc9xrWW3VEtnhC"
      c.subscribe "Ntpx892i59vnutdwttp2zLIg", params[:email]
    rescue Cindy::AlreadySubscribed => e
    end
  end

  def demo_user
    sign_in(:user, create_guest_user)
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  def get_ranked_graph_data(season)
    ranked_wr_args = { :klasses_array => Klass::LIST,
                       :beginday      => 2.weeks.ago,
                       :endday        => Time.zone.now.beginning_of_day}
    ranked_wr_count = Match.get_klass_ranked_wr(ranked_wr_args)
    @ranked_winrates = ranked_wr_count[0]
    gon.counts = ranked_wr_count[1]
  end

  def liquid_data
    unless current_user_allow?([:plat, :admin])
      redirect_to root_path and return
    end
    klass_ranked_wr = Match.get_klass_ranked_wr(2.weeks.ago, 
                                                DateTime.now)
    render json: klass_ranked_wr
  end

  def generate_report
    # if !current_user.is_admin?
    #   redirect_to root_path, alert: "y u no admin" and return
    # end
    season = Season.find(14)
    args = { :beginday => season.begin, :endday => season.end, :klasses_array => Klass::LIST }
    ranked_wr_count = Match.get_klass_ranked_wr(args)
    @ranked_winrates = ranked_wr_count[0]
    gon.counts = ranked_wr_count[1]

    @prev_global = [
      {"Warlock" => 48.96, "Druid" => 45.96, "Shaman" => 49.62, "Rogue" => 51.91, "Warrior" => 45.55, "Paladin" => 52.65, "Mage" => 53.27, "Hunter" => 45.11, "Priest" => 49.04},
      {"Warlock" => 51.09, "Druid" => 48.75, "Shaman" => 50.49, "Rogue" => 44.11, "Warrior" => 50.91, "Paladin" => 49.34, "Mage" => 48.76, "Hunter" => 53.99, "Priest" => 47.37}
    ]

    matches = Match.where(season_id: season.id).all
    # Determine match Class Win Rates
    @classes_array = Klass.list
    classes = Klass.list
    @classarenarate = Hash.new
    @arenatot = Hash.new
    mode_matches = matches.select{|q| q.mode_id == 1}
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = mode_matches.select {|q| q.klass_id == klasses_hash[c] && q.result_id == 1}.count + mode_matches.select {|q| q.oppclass_id == klasses_hash[c] && q.result_id == 2}.count
      totalgames = mode_matches.select {|q| q.klass_id == klasses_hash[c]}.count + mode_matches.select { |q| q.oppclass_id == klasses_hash[c]}.count
      if totalgames == 0
        @classarenarate[c] = 0
      else
        @classarenarate[c] = (totalwins.to_f / totalgames)
      end
      @arenatot[c] = totalgames

    end
    @classarenarate = @classarenarate.sort_by { |name, winsrate| winsrate }.reverse

    # Determine mode_matches Class Win Rates

    @classconrate = Hash.new
    @contot = Hash.new
    mode_matches = matches.select {|q| q.mode_id == 3}
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = mode_matches.select {|q| q.result_id == 1 && q.klass_id == klasses_hash[c]}.count
      totalwins = totalwins + mode_matches.select {|q| q.oppclass_id == klasses_hash[c] && q.result_id == 2}.count
      totalgames = mode_matches.select { |q| q.klass_id == klasses_hash[c]}.count + mode_matches.select { |q| q.oppclass_id == klasses_hash[c]}.count
      if totalgames == 0
        @classconrate[c] = 0
      else
        @classconrate[c] = (totalwins.to_f / totalgames)
      end

      @contot[c] = totalgames
    end
    @classconrate = @classconrate.sort_by { |name, winsrate| winsrate }.reverse

    # Most Played

    @conclassnum = Hash.new
    classes.each do |a|
      @conclassnum[a] = @arenatot[a] + @contot[a]
    end

    # Determine mode_matches Class Win Rates
    # classcombos = classes.combination(2).to_a
    classcombos = Array.new
    classes.each do |c|
      classes.each do |c2|
        classcombos << [c,c2]
      end
    end
    @userarenarate = Array.new
    @totarenagames = Hash.new
    mode_matches = matches.select { |q| q.mode_id == 1}
    classcombos.each_with_index do |combo, i|
      totalwins = 0
      totalgames = 0
      totalwins = mode_matches.select { |q| q.klass_id == klasses_hash[combo[0]] && q.oppclass_id == klasses_hash[combo[1]] && q.result_id == 1}.count + mode_matches.select { |q| q.klass_id == klasses_hash[combo[1]] && q.oppclass_id == klasses_hash[combo[0]] && q.result_id == 2}.count
      totalgames = mode_matches.select { |q| q.klass_id == klasses_hash[combo[0]] && q.oppclass_id == klasses_hash[combo[1]]}.count + mode_matches.select { |q| q.klass_id == klasses_hash[combo[1]] && q.oppclass_id == klasses_hash[combo[0]]}.count
      @userarenarate << [ combo[0], [combo[1], (totalwins.to_f / totalgames)]]
    end
    # Determine mode_matches Class Win Rates
    @conrate = Array.new
    @totcongames = Hash.new
    mode_matches = matches.select {|q| q.mode_id == 3}
    classcombos.each_with_index do |combo, i|
      totalwins = 0
      totalgames = 0

      totalwins = mode_matches.select { |q| q.oppclass_id == klasses_hash[combo[1]] && q.result_id == 1 && q.klass_id == klasses_hash[combo[0]]}.count
      totalwins = totalwins + mode_matches.select { |q| q.oppclass_id == klasses_hash[combo[0]] && q.result_id == 2 && q.klass_id == klasses_hash[combo[1]]}.count

      totalgames = mode_matches.select{ |q| q.oppclass_id == klasses_hash[combo[0]] && q.klass_id == klasses_hash[combo[1]]}.count + mode_matches.select {|q| q.oppclass_id == klasses_hash[combo[1]] && q.klass_id == klasses_hash[combo[0]]}.count

      @conrate << [ combo[0], [combo[1], (totalwins.to_f / totalgames)]]
    end

    # mode_matches Runs Data
    @arena_runs = Array.new
    classes.each_with_index do |c,i|
      run_count = Array.new(13,0)
      tot_games = ArenaRun.where{(klass_id == i+1) & (created_at >= season.begin)}.count
      ArenaRun.where(klass_id: i+1).includes(:matches).each do |ar|
        run_count[ar.matches.where(result_id: 1).count] += 1 unless ar.matches.where(result_id: 1).count > 12
      end
      run_percent = run_count.map { |e| e.to_f / tot_games }
      @arena_runs << [c, run_count, run_percent]
    end
    html = render_to_string(layout: 'fullpage')
    File.open("#{Rails.root}/public/reports/#{Time.now.strftime('%d_%m_%Y')}.html", 'w') {|f| f.write(html) }
    render layout: 'fullpage'
  end

  private

  def cularenagames(race, days1)
    wins = Array.new(days1, 0)
    wins[0] = 0
    (1..days1).each do |i|
      wins[i] = mode_matches.where(klass: race, result_id: 1).where(created_at: i.days.ago.beginning_of_day..i.days.ago.end_of_day).count
    end
    return wins
  end

  def culcongames(race, days1)
    wins = Array.new(days1, 0)
    wins[0] = 0
    (1..days1).each do |i|
      wins[i] = mode_matches.joins(:deck).where(:result_id => 1, 'decks.race' => race).where(created_at: i.days.ago.beginning_of_day..i.days.ago.end_of_day).count
    end
    return wins
  end

  def create_guest_user
    u = User.create(email: "guest_#{Time.now.to_i}#{rand(999)}@example.com", password: "demouser", guest: true)
    u.save!(validate: false)
    session[:guest_user_id] = u.id

    u
  end

  def get_top_streamers
    begin
      top_streams = Rails.cache.write("top_streams", expires_in: 30.minutes) do
        HTTParty.get('https://api.twitch.tv/kraken/search/streams?limit=50&q=hearthstone&client_id=5p5btpott5bcxwgk46azv8tkq49ccrv')['streams']
      end
    rescue
    end
    top_streams = [] if top_streams.class != Array

    top_streams
  end

  def round_down(num, n)
    n < 1 ? num.to_i.to_f : (num - 0.5 / 10**n).round(n)
  end
end
