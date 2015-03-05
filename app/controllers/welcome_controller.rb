class WelcomeController < ApplicationController
  def index

    # Global Stats
    @arena_top = Rails.cache.read('wel#arena_top') || []
    @con_top = Rails.cache.read('wel#con_top') || []

    # Decklists
    @recentdecks = Rails.cache.fetch('wel#recent_deck') do
      Deck.where(is_public: true).
              joins(:unique_deck).
              last(7)
    end
    @topdecks =
      Deck.where(is_public: true).where('decks.created_at >= ?', 1.week.ago).
                group(:unique_deck_id).
                joins(:unique_deck).
                joins(:user).
                where("unique_decks.num_matches >= ?", 30).
                sort_by { |deck| deck.unique_deck.winrate || 0 }.
                last(7).
                reverse.
                to_a
    # Get Class Use % by Rank

    @rank_class = Rails.cache.fetch('rank_class', expires_in: 12.hours) do
      rank_class = Match.rank_class(12).select {|rank, match| match.count == 9}
      rank_percent = {}
      rank_class.each do |rank, counts|
        tot = counts.map{|w|w[1]}.reduce(:+)
        percent = counts.map {|klass, count| [klass, count.to_f/tot*100]}
        rank_percent[rank] = percent
      end

      rank_percent
    end

    @rank_class = {7=>[[1, 6.756756756756757], [2, 23.64864864864865], [3, 10.81081081081081], [4, 24.324324324324326], [5, 3.3783783783783785], [6, 22.2972972972973], [7, 2.7027027027027026], [8, 2.027027027027027], [9, 4.054054054054054]], 9=>[[1, 12.132352941176471], [2, 19.11764705882353], [3, 26.838235294117645], [4, 12.867647058823529], [5, 6.61764705882353], [6, 5.514705882352941], [7, 0.7352941176470588], [8, 6.61764705882353], [9, 9.558823529411764]], 10=>[[1, 16.3265306122449], [2, 20.99125364431487], [3, 20.699708454810494], [4, 5.830903790087463], [5, 4.956268221574344], [6, 10.787172011661808], [7, 3.7900874635568513], [8, 10.495626822157435], [9, 6.122448979591836]], 11=>[[1, 12.933025404157044], [2, 20.554272517321014], [3, 18.937644341801384], [4, 6.0046189376443415], [5, 3.233256351039261], [6, 8.775981524249422], [7, 9.468822170900692], [8, 9.237875288683602], [9, 10.854503464203233]], 12=>[[1, 15.091210613598674], [2, 21.724709784411278], [3, 15.754560530679933], [4, 7.462686567164178], [5, 6.965174129353234], [6, 8.45771144278607], [7, 6.799336650082918], [8, 8.623548922056385], [9, 9.12106135986733]], 13=>[[1, 10.326086956521738], [2, 26.08695652173913], [3, 16.032608695652172], [4, 14.538043478260871], [5, 6.25], [6, 6.7934782608695645], [7, 6.657608695652175], [8, 5.163043478260869], [9, 8.152173913043478]]}

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

  def jan_report
    render file: "#{Rails.root}/public/reports/2015/jan.html", layout: false
  end

  def decreport
    render layout: 'fullpage'
  end

  def april_report
    render file: "#{Rails.root}/public/reports/april_report.html", layout: 'fullpage'
  end

  def may_report
    render file: "#{Rails.root}/public/reports/may_report.html", layout: 'fullpage'
  end

  def june_report
    render file: "#{Rails.root}/public/reports/june_report.html", layout: 'fullpage'
  end

  def july_report
    render file: "#{Rails.root}/public/reports/july_report.html", layout: 'fullpage'
  end

  def aug_report
    render file: "#{Rails.root}/public/reports/aug_report.html", layout: 'fullpage'
  end

  def sept_report
    render file: "#{Rails.root}/public/reports/sept_report.html", layout: 'fullpage'
  end

  def sept_post_report
    render file: "#{Rails.root}/public/reports/sept_post_nerf.html", layout: 'fullpage'
  end

  def oct_report
    render file: "#{Rails.root}/public/reports/oct_report.html", layout: 'fullpage'
  end

  def novreport
    render layout: 'fullpage'
  end

  def gvgreport
    render file: "#{Rails.root}/public/reports/gvg/index.html", layout: false
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

end
