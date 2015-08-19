namespace :cron do
  desc "Get new class graph data for homepage"
  # NEEDS TO BE OPTIMIZED
  task :welcome_cache => :environment do
    matches = Match.where{(created_at >= 2.weeks.ago) & (created_at <= 1.day.ago)}.all
    con_matches = matches.select {|m| m.mode_id == 3}
    arena_matches = matches.select {|m| m.mode_id == 1}
    arena_top = []
    con_top = []
    Klass::LIST.each do |klass_id, class_name|
      # Calculate klass_wr per day
      klass_wr = {}
      klass_con_matches = con_matches.select {|m| m.klass_id == klass_id }
      con_day_matches = klass_con_matches.group_by {|m| m.created_at.beginning_of_day}
      con_day_matches.each do |date, day_matches|
        win_count = day_matches.select {|m| m.result_id == 1}.count
        tot_games = day_matches.count
        klass_wr[date] = (win_count.to_f/tot_games * 100).round(2)
      end
      Rails.cache.delete("con#wr_rate-#{klass_id}")
      Rails.cache.write("con#wr_rate-#{klass_id}", klass_wr)
      p "Finished con#wr " + class_name + " cache preheating"

      # Calculate arena top wrs
      klass_arena_matches = arena_matches.select {|m| m.klass_id == klass_id}
      wins = klass_arena_matches.select{|m| m.result_id == 1}.count
      total = klass_arena_matches.count
      arena_top[klass_id - 1] = [class_name, (wins.to_f/total* 100).round(2)]

      # Calculate constructed top wrs
      klass_con_matches = con_matches.select {|m| m.klass_id == klass_id}
      wins = klass_con_matches.select{|m| m.result_id == 1}.count
      total = klass_con_matches.count
      con_top[klass_id - 1] = [class_name, (wins.to_f/total* 100).round(2)]
    end
    Rails.cache.delete('wel#arena_top')
    p arena_top.inspect
    sorted_arena = arena_top.sort_by {|name, wr| wr.nan? ? 0 : wr}.reverse.shift(5)
    Rails.cache.write('wel#arena_top', sorted_arena)
    p "Arena top classes preheated"

    p con_top.inspect
    Rails.cache.delete('wel#con_top')
    sorted_con = con_top.sort_by {|name, wr| wr.nan? ? 0 : wr}.reverse.shift(5)
    Rails.cache.write('wel#con_top', sorted_con)
    p "Con top classes preheated"
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
    rank_class = Match.rank_class(12).select {|rank, match| match.count == 9}
    rank_percent = {}
    rank_class.each do |rank, counts|
      tot = counts.map{|w|w[1]}.reduce(:+)
      percent = counts.map {|klass, count| [klass, round_down(count.to_f/tot*100, 2)]}
      rank_percent[rank] = percent
    end

    Rails.cache.write('wel#rank_class', rank_percent)
  end
  

  task :market_top_decks => :environment do
    Rails.cache.delete('market_top_deck')
    decks = Deck.where(is_public: [true, nil]).where('decks.created_at >= ?', 1.week.ago).
      group(:unique_deck_id).
      joins(:unique_deck).
      joins(:user).
      where("unique_decks.num_matches >= ?", 30).
      sort_by { |deck| deck.unique_deck.winrate || 0 }.
      last(20).
      reverse.
      to_a
    Rails.cache.write('market_top_deck', decks)
  end

  def round_down(num, n)
    n < 1 ? num.to_i.to_f : (num - 0.5 / 10**n).round(n)
  end

end
