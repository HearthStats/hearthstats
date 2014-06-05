class WelcomeController < ApplicationController
  def index
    render layout: false
  end
  # Past last patch
  # where("created_at between ? and ?", Time.at(1386633600).to_datetime, Date.current.end_of_day)
  def demo_user
    sign_in(:user, create_guest_user)
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
    end
  end

  def ranked_test
    season = 6
    ranked_wr_count = get_klass_ranked_wr(season)
    @ranked_winrates = ranked_wr_count[0]
    @ranked_counts = ranked_wr_count[1]
    gon.counts = ranked_wr_count[1]

    # @ranked_array = [[[[0, 52.33], [1, 52.71], [2, 55.8], [3, 58.63], [4, 52.8], [5, 53.8], [6, 47.93], [7, 52.25], [8, 50.47], [9, 51.13], [10, 52.14], [11, 55.8], [12, 56.07], [13, 55.63], [14, 56.32], [15, 59.96], [16, 57.56], [17, 62.23], [18, 57.58], [19, 58.47], [20, 60.29], [21, 50.0], [22, 63.33], [23, 45.45], [24, 75.0], [25, 61.54]], [86, 129, 224, 249, 339, 513, 555, 555, 529, 618, 888, 742, 758, 960, 941, 1019, 714, 593, 561, 301, 277, 24, 30, 11, 4, 13]], [[[0, 55.56], [1, 51.65], [2, 51.4], [3, 51.41], [4, 52.89], [5, 52.19], [6, 50.87], [7, 54.61], [8, 56.22], [9, 53.44], [10, 54.14], [11, 55.27], [12, 56.08], [13, 57.25], [14, 56.03], [15, 57.03], [16, 58.33], [17, 59.09], [18, 61.38], [19, 60.18], [20, 63.4], [21, 71.05], [22, 70.37], [23, 84.62], [24, 100.0], [25, 61.36]], [18, 395, 712, 1204, 1677, 2470, 1907, 1659, 1455, 1613, 2285, 1896, 2074, 2180, 2206, 2469, 1591, 1469, 1090, 776, 642, 38, 27, 13, 2, 44]], [[[0, 70.0], [1, 58.11], [2, 47.45], [3, 49.55], [4, 53.15], [5, 50.66], [6, 54.1], [7, 48.03], [8, 49.66], [9, 50.47], [10, 53.74], [11, 52.55], [12, 55.11], [13, 54.87], [14, 54.54], [15, 56.61], [16, 57.55], [17, 60.68], [18, 62.21], [19, 60.95], [20, 66.86], [21, 69.23], [22, 81.25], [23, 77.78], [24, 69.23], [25, 60.98]], [10, 74, 196, 446, 587, 835, 634, 585, 737, 745, 1096, 923, 998, 1026, 981, 1157, 742, 679, 598, 402, 341, 39, 16, 18, 13, 41]], [[[0, 56.16], [1, 51.04], [2, 54.64], [3, 54.34], [4, 48.62], [5, 50.23], [6, 49.18], [7, 50.0], [8, 46.86], [9, 49.43], [10, 52.35], [11, 52.84], [12, 53.17], [13, 52.19], [14, 50.85], [15, 52.24], [16, 50.74], [17, 55.6], [18, 57.18], [19, 53.2], [20, 53.98], [21, 57.14], [22, 44.44], [23, 66.67], [24, 42.86], [25, 50.0]], [73, 192, 485, 541, 689, 1071, 795, 552, 636, 876, 1062, 1005, 867, 981, 1056, 1271, 808, 937, 759, 485, 452, 42, 18, 6, 7, 2]], [[[0, 100.0], [1, 75.0], [2, 26.67], [3, 49.45], [4, 49.12], [5, 45.79], [6, 43.84], [7, 42.45], [8, 47.56], [9, 47.87], [10, 41.06], [11, 53.07], [12, 45.41], [13, 46.56], [14, 48.5], [15, 52.01], [16, 52.68], [17, 51.87], [18, 55.7], [19, 54.48], [20, 60.14], [21, 67.31], [22, 58.7], [23, 81.25], [24, 33.33], [25, 100.0]], [1, 4, 15, 91, 171, 190, 276, 245, 349, 399, 738, 635, 577, 698, 1101, 1367, 987, 964, 894, 591, 592, 52, 46, 16, 12, 5]], [[[0, 33.33], [1, 48.15], [2, 40.2], [3, 49.74], [4, 54.51], [5, 51.88], [6, 47.74], [7, 51.41], [8, 49.05], [9, 52.54], [10, 52.32], [11, 54.32], [12, 49.32], [13, 51.12], [14, 54.1], [15, 53.23], [16, 52.59], [17, 56.05], [18, 62.44], [19, 58.73], [20, 56.13], [21, 62.5], [22, 54.17], [23, 68.42], [24, 61.54], [25, 100.0]], [21, 27, 102, 382, 521, 719, 576, 533, 473, 611, 820, 556, 511, 712, 719, 804, 559, 537, 394, 252, 310, 24, 24, 19, 13, 4]], [[[0, 60.0], [1, 55.32], [2, 47.46], [3, 51.37], [4, 52.64], [5, 55.19], [6, 50.61], [7, 50.15], [8, 48.79], [9, 52.08], [10, 52.24], [11, 51.41], [12, 53.03], [13, 50.0], [14, 51.93], [15, 53.54], [16, 54.12], [17, 51.44], [18, 54.0], [19, 62.06], [20, 62.23], [21, 74.19], [22, 67.8], [23, 94.74], [24, 81.82], [25, 57.14]], [15, 47, 118, 292, 397, 453, 245, 341, 371, 384, 626, 566, 677, 782, 880, 1425, 850, 935, 987, 601, 654, 62, 59, 19, 11, 21]], [[[0, 42.55], [1, 52.17], [2, 43.82], [3, 51.4], [4, 42.94], [5, 52.82], [6, 46.91], [7, 52.96], [8, 53.85], [9, 51.51], [10, 50.08], [11, 48.74], [12, 51.43], [13, 52.49], [14, 50.23], [15, 54.29], [16, 54.63], [17, 59.2], [18, 55.57], [19, 57.97], [20, 61.09], [21, 64.04], [22, 69.05], [23, 72.22], [24, 57.14], [25, 54.17]], [47, 23, 89, 107, 177, 248, 243, 253, 286, 398, 593, 636, 803, 903, 1101, 1433, 1091, 1044, 871, 728, 884, 89, 42, 18, 7, 24]], [[[0, 52.05], [1, 45.6], [2, 50.88], [3, 47.81], [4, 52.54], [5, 50.7], [6, 50.0], [7, 51.4], [8, 51.3], [9, 51.82], [10, 51.58], [11, 54.84], [12, 56.47], [13, 53.8], [14, 54.58], [15, 54.9], [16, 57.16], [17, 56.48], [18, 55.62], [19, 49.18], [20, 53.22], [21, 55.77], [22, 50.0], [23, 88.89], [24, 100.0], [25, 75.0]], [73, 125, 226, 686, 887, 1215, 1002, 928, 844, 1179, 1454, 1249, 1229, 1225, 1277, 1399, 950, 733, 712, 488, 1148, 52, 26, 9, 1, 8]]]
  end


  def generate_report
    if !current_user.is_admin?
      redirect_to root_path, alert: "Y U NO ADMIN" and return
    end
    matches = Match.where(season_id: 6)
    # Determine match Class Win Rates
    @classes_array = Klass.list
    classes = Klass.list
    @classarenarate = Hash.new
    @arenatot = Hash.new
    mode_matches = matches.where(mode_id: 1)
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = mode_matches.where(klass_id: klasses_hash[c], result_id: 1).count + mode_matches.where(oppclass_id: klasses_hash[c], result_id: 2).count
      totalgames = mode_matches.where(klass_id: klasses_hash[c]).count + mode_matches.where(oppclass_id: klasses_hash[c]).count
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
    mode_matches = matches.where(mode_id: 3)
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = mode_matches.where(result_id: 1, klass_id: klasses_hash[c]).count
      totalwins = totalwins + mode_matches.where(oppclass_id: klasses_hash[c], result_id: 2).count
      totalgames = mode_matches.where(klass_id: klasses_hash[c]).count + mode_matches.where(oppclass_id: klasses_hash[c]).count
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
    mode_matches = matches.where(mode_id: 1)
    classcombos.each_with_index do |combo, i |
      totalwins = 0
      totalgames = 0
      totalwins = mode_matches.where(klass_id: klasses_hash[combo[0]], oppclass_id: klasses_hash[combo[1]], result_id: 1).count + mode_matches.where(klass_id: klasses_hash[combo[1]], oppclass_id: klasses_hash[combo[0]], result_id: 2).count
      totalgames = mode_matches.where(klass_id: klasses_hash[combo[0]], oppclass_id: klasses_hash[combo[1]],result_id: [1,2]).count + mode_matches.where(klass_id: klasses_hash[combo[1]], oppclass_id: klasses_hash[combo[0]],result_id: [1,2]).count
      @userarenarate << [ combo[0], [combo[1], (totalwins.to_f / totalgames)]]
    end
    # Determine mode_matches Class Win Rates
    @conrate = Array.new
    @totcongames = Hash.new
    mode_matches = matches.where(mode_id: 3)
    classcombos.each_with_index do |combo, i |
      totalwins = 0
      totalgames = 0

      totalwins = mode_matches.where(oppclass_id: klasses_hash[combo[1]], result_id: 1, klass_id: klasses_hash[combo[0]]).count
      totalwins = totalwins + mode_matches.where(oppclass_id: klasses_hash[combo[0]], result_id: 2, klass_id: klasses_hash[combo[1]]).count

      totalgames = mode_matches.where(oppclass_id: klasses_hash[combo[0]], klass_id: klasses_hash[combo[1]], result_id: [1,2]).count + mode_matches.where(oppclass_id: klasses_hash[combo[1]], klass_id: klasses_hash[combo[0]], result_id: [1,2]).count

      @conrate << [ combo[0], [combo[1], (totalwins.to_f / totalgames)]]
    end

    # mode_matches Runs Data
    @arena_runs = Array.new
    classes.each_with_index do |c,i|
      run_count = Array.new(13,0)
      tot_games = ArenaRun.where(klass_id: i+1).count
      ArenaRun.where(klass_id: i+1).each do |ar|
        run_count[ar.matches.where(result_id: 1).count] += 1 unless ar.matches.where(result_id: 1).count > 12
      end
      run_percent = run_count.map { |e| e.to_f / tot_games }
      @arena_runs << [c, run_count, run_percent]
    end
    html = render_to_string(layout: 'fullpage')
    File.open("#{Rails.root}/public/reports/april_report.html", 'w') {|f| f.write(html) }
    render layout: 'fullpage'
  end

  def decreport
    render layout: 'fullpage'
  end

  def april_report
    render file: "#{Rails.root}/public/reports/april_report.html", layout: 'fullpage'
  end

  def novreport
    render layout: 'fullpage'
  end

  private

    def cularenagames(race, days1)
      wins = Array.new(days1, 0)
      wins[0] = 0
      (1..days1).each do |i|
        wins[i] = mode_matches.where(klass: race, result_id: true).where(created_at: i.days.ago.beginning_of_day..i.days.ago.end_of_day).count + mode_matches.where(oppclass_id: race, result_id: false).where(created_at: i.days.ago.beginning_of_day..i.days.ago.end_of_day).count
      end
      return wins
    end

    def culcongames(race, days1)
      wins = Array.new(days1, 0)
      wins[0] = 0
      (1..days1).each do |i|
        wins[i] = mode_matches.joins(:deck).where(:result_id => true, 'decks.race' => race).where(created_at: i.days.ago.beginning_of_day..i.days.ago.end_of_day).count + mode_matches.where(oppclass_id: race, result_id: false).where(created_at: i.days.ago.beginning_of_day..i.days.ago.end_of_day).count
      end
      return wins
    end

    def create_guest_user
      u = User.create(email: "guest_#{Time.now.to_i}#{rand(999)}@example.com", password: "demouser", guest: true)
      u.save!(validate: false)
      session[:guest_user_id] = u.id

      u
    end

    def get_klass_ranked_wr(season)
      ranked_stats_array = Array.new
      ranked_count_array = Hash.new
      Klass.all.each do |klass|
        winrate = get_rank_wr_array_for_klass(klass, season)
        ranked_stats_array << winrate.win_rate_array
        ranked_count_array[klass.name] = winrate.win_counts
      end

      [ranked_stats_array, ranked_count_array]
    end

    Winrate = Struct.new(:win_rate_array, :win_counts)
    def get_rank_wr_array_for_klass(klass, season)
      klass_wr = Array.new
      match_count = Array.new
      Rank.all.each do |rank|
        matches = rank.matches.where(klass_id: klass.id, season_id: season)
        id = rank.id
        if rank.id == 26
          id = 0
          klass_wr.unshift([id, get_win_rate(matches)])
          match_count.unshift(matches.length)
        else
          klass_wr << [id, get_win_rate(matches)]
          match_count << matches.length
        end
      end

      output = Winrate.new(klass_wr, match_count)
    end

end
