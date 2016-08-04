namespace :stats do
  desc "Get class winrates & at ranks"

  task :overallclassrates => :environment do
    matches = Match.where{(created_at >= 2.weeks.ago) & (created_at <= 1.day.ago)}.all
    con_matches = matches.select {|m| m.mode_id == 3}
    Klass::LIST.each do |klass_id, class_name|
      klass_con_matches = con_matches.select {|m| m.klass_id == klass_id }
      win_count = klass_con_matches.select {|m| m.result_id == 1}.count
      tot_games = klass_con_matches.count
      klass_wr = (win_count.to_f/tot_games * 100).round(2)
      p class_name.to_s + " : " + klass_wr.to_s + "%"
    end
  end

  task :rankrates => :environment do
    matches = Match.where{(created_at >= 2.weeks.ago) & (created_at <= 1.day.ago) & (mode_id == 3)}.all
    all_matches = matches.select { |m| m.rank != nil }
    for r in 0..25 do
      p r
      ranked_matches = all_matches.select { |m| m.rank == i }
      num_ranked_matches = ranked_matches.count
      Klass::LIST.each do |klass_id, class_name|
        klass_ranked_matches = ranked_matches.select {|m| m.klass_id == klass_id }
        win_count = klass_ranked_matches.select {|m| m.result_id == 1}.count
        tot_games = klass_ranked_matches.count
        ranked_wr = (win_count.to_f/tot_games * 100).round(2)
        klass_percent = (tot_games.to_f/num_ranked_matches * 100).round(2)
        p class_name + " | winrate: " + ranked_wr.to_s + " | % of rank: " + klass_percent.to_s
      end
    end
  end
end