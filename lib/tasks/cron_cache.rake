namespace :cron do
  desc "Get new class graph data for homepage"
  # NEEDS TO BE OPTIMIZED
  task :welcome_cache => :environment do
    matches = Match.where{(created_at >= 3.days.ago) & (created_at <= 1.day.ago)}.all
    con_matches = matches.select {|m| m.mode_id == 3}
    Klass::LIST.each do |klass_id, class_name|
      # Calculate klass_wr per day
      klass_wr = {}
      klass_con_matches = con_matches.select {|m| m.klass_id == klass_id }
      con_day_matches = klass_con_matches.group_by {|m| m.created_at.beginning_of_day}
      con_day_matches.each do |date, day_matches|
        win_count = day_matches.select {|m| m.result_id == 1}.count
        tot_games = day_matches.size
        klass_wr[date] = (win_count.to_f/tot_games * 100).round(2)
      end
      Rails.cache.delete("con#wr_rate-#{klass_id}")
      Rails.cache.write("con#wr_rate-#{klass_id}", klass_wr)
      p "Finished con#wr " + class_name + " cache preheating"
    end
  end

  task :expire_top_decks => :environment do
    Rails.cache.delete('wel#top_deck')
    ActionController::Base.new.expire_fragment('top_decks')
  end

  task :expire_recent_decks => :environment do
    Rails.cache.delete('wel#recent_deck')
    ActionController::Base.new.expire_fragment('recent_decks')
  end

  task :get_top_streamers => :environment do
    ActionController::Base.new.expire_fragement('top_streamers')
  end

  task :get_top_archtypes => :environment do
    # WIP
    matches = Match.joins(:decks).joins(:unique_decks).where("created_at >= ?", 12.hour.ago).where(mode_id: 3)
    matches.collect { |match| match.archtype_id }
    Rails.cache.delete('dash#top_archtype')
    Rails.cache.write('dash#top_archtype', top_archtypes)
  end

  task :archetype_pop => :environment do
    Rails.cache.delete('archetype_pop')
    arche = UniqueDeckType.get_type_popularity(2)
    Rails.cache.write('archetype_pop', arche)
  end

  task :archetype_decks => :environment do
    Rails.cache.delete('top_adecks')
    decks = UniqueDeckType.get_top_decks
    Rails.cache.write('top_adecks', decks)
  end

  task :top_decks => :environment do
    Rails.cache.delete('top_decks')
    decks = Deck.get_top_decks
    Rails.cache.write('top_decks', decks)
  end

  task :rank_class => :environment do
    Rails.cache.delete('wel#rank_class')
    # Check if the rank has matches vs all 9 klasses
    rank_class = Match.rank_class(12).select {|rank, match| match.size == 9}
    rank_percent = {}
    rank_class.each do |rank, counts|
      tot = counts.map{|w|w[1]}.reduce(:+)
      percent = counts.map {|klass, count| [klass, round_down(count.to_f/tot*100, 2)]}
      rank_percent[rank] = percent
    end

    Rails.cache.write('wel#rank_class', rank_percent)
  end

  def round_down(num, n)
    n < 1 ? num.to_i.to_f : (num - 0.5 / 10**n).round(n)
  end

end
