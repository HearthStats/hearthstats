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

