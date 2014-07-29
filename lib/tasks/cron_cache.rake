namespace :cron do
  desc "Get new class graph data for homepage"
  task :con_wr => :environment do
    matches = Match.where('created_at >= ?', 2.weeks.ago)
    Klass.list.each_with_index do |klass, i|
      klass_matches = matches.where(klass_id: i+1).group_by_day(:created_at)  
      wins = klass_matches.where(result_id: 1).count
      tot = klass_matches.count
      klass_wr =  Hash.new
      wins.zip(tot).map do |x, y| 
        wr =  ((x[1].to_f/y[1] rescue 0)*100).round(2)
        wr = 0 if wr.nan? || wr == Float::INFINITY
        klass_wr[x[0]] = wr
      end
      Rails.cache.delete("con#wr_rate-#{i+1}")
      Rails.cache.write("con#wr_rate-#{i+1}", klass_wr)
      p "Finished con#wr cache preheating"
    end
  end
end
