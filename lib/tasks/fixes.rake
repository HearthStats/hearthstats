task :ArenaIdFix => :environment do
  games = Arena.where(user_id: nil)
  i = 0
  games.each do |g|
    uid = ArenaRun.find(g.arena_run_id).user_id
    g.user_id = uid
    g.save
    i += 1
  end
  p i.to_s + " games fixed."
end

task :UniqueDeckStatsFix => :environment do
  STDOUT.sync = true
  unique_decks = Match.where{created_at >= Date.today.beginning_of_day}.
    map{|e| e.unique_deck}.
    uniq
  tot = unique_decks.count
  count = 0
  unique_decks.each do |ud|
    UniqueDeck.update_stats(ud.id) if ud
    count += 1
    p count.to_f/tot * 100
  end
end
