class Profile < ActiveRecord::Base
  attr_accessible :bnetid, :name, :private, :bnetnum, :time_zone, :avatar
  has_attached_file :avatar, :default_url => "/assets/avatar.jpg", styles:{
    thumb: '29x29>',
    square: '200x200#',
    medium: '300x300>'
  }
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  belongs_to :users
  is_impressionable

	def self.get_recent_games(userid)
    con = Match.where( mode_id:[2..3], user_id: userid ).last(3)
		arena = Match.where( mode_id: 1, user_id: userid ).last(3)
		i = 0
		recent_games = Array.new
		con.each do |d|
      if !d.deck.nil?
        recent_games[i] = ["Constructed", d.deck.name, Klass.find(d.oppclass_id).name, d.result_id, d.created_at]
				i += 1
			end
		end
		arena.each do |d|
			if !d.nil?
        recent_games[i] = ["Arena", Klass.find(d.klass_id).name, Klass.find(d.oppclass_id).name, d.result_id, d.created_at]
				i += 1
			end
		end
		recent_games.sort_by! { |a| a[4] }
		recent_games.reverse!

		recent_games
	end

end
