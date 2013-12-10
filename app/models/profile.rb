class Profile < ActiveRecord::Base
  attr_accessible :bnetid, :name, :private, :bnetnum
  belongs_to :users
  is_impressionable

	def self.get_recent_games(userid)
		con = Constructed.where(user_id: userid).last(3)
		arena = Arena.where(user_id: userid).last(3)
		i = 0
		recent_games = Array.new
		con.each do |d|
			if !d.nil?
				recent_games[i] = ["Constructed", d.deck.race, d.oppclass, d.win, d.created_at]
				i += 1
			end
		end
		arena.each do |d|
			if !d.nil?
				recent_games[i] = ["Arena", d.userclass, d.oppclass, d.win, d.created_at]
				i += 1
			end
		end
		recent_games.sort_by! { |a| a[4] }
		recent_games.reverse!

		recent_games
	end

end
