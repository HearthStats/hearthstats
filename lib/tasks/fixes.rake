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

task :FixDeckStrings => :environment do
  Deck.where{created_at >= 1.month.ago}.find_each do |deck|
    if deck.cardstring && /,_2|,_1/.match(deck.cardstring)
      deck.update_attribute(:cardstring, deck.cardstring.gsub(%r{,_2|,_1},""))
      p deck.name + "Updated"
    end
  end
end

task :match_deck_version_id => :environment do
  MatchDeck.where(deck_version_id: 1).find_each do |md|
    begin
      md.deck_version_id = md.deck.deck_versions.last.id
      md.save
    rescue
    end
  end
end