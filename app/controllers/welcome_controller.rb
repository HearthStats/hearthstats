class WelcomeController < ApplicationController
	caches_action :janreport ,expires_in: 1.day
	def index
		render :layout=>false
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


	def janreport
		# Determine Arena Class Win Rates
		@classesArray = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
		classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
		@classarenarate = Hash.new
		@arenatot = Hash.new
		classes.each do |c|
			totalwins = 0
			totalgames = 0
			totalwins = Arena.where("created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(:userclass => c, :win => true).count + Arena.where("created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(:oppclass => c, :win => false).count
			totalgames = Arena.where("created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(:userclass => c).count + Arena.where("created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(:oppclass => c).count
			if totalgames == 0
				@classarenarate[c] = 0
			else
				@classarenarate[c] = (totalwins.to_f / totalgames)
			end
			@arenatot[c] = totalgames

		end
		@classarenarate = @classarenarate.sort_by { |name, winsrate| winsrate }.reverse

		# Determine Constructed Class Win Rates

		@classconrate = Hash.new
		@contot = Hash.new
		classes.each do |c|
			totalwins = 0
			totalgames = 0
			totalwins = Constructed.joins(:deck).where("constructeds.created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(win: true, 'decks.race' => c).count
			totalwins = totalwins + Constructed.where("created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(oppclass: c, win: false).count
			totalgames = Constructed.joins(:deck).where("constructeds.created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where('decks.race' => c).count + Constructed.where("created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(oppclass: c).count
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

		# Determine Arena Class Win Rates
		# classcombos = classes.combination(2).to_a
		classcombos = Array.new
		classes.each do |c|
			classes.each do |c2|
				classcombos << [c,c2]
			end
		end
		@userarenarate = Array.new
		@totarenagames = Hash.new
		classcombos.each_with_index do |combo, i |
			totalwins = 0
			totalgames = 0
			totalwins = Arena.where("arenas.created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(userclass: combo[0], oppclass: combo[1], win: true).count + Arena.where("created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(userclass: combo[1], oppclass: combo[0], win: false).count
			totalgames = Arena.where("arenas.created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(userclass: combo[0], oppclass: combo[1]).count + Arena.where("created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(userclass: combo[1], oppclass: combo[0]).count
			@userarenarate << [ combo[0], [combo[1], (totalwins.to_f / totalgames)]]
		end
		# Determine Constructed Class Win Rates
		@conrate = Array.new
		@totcongames = Hash.new
		classcombos.each_with_index do |combo, i |
			totalwins = 0
			totalgames = 0

			totalwins = Constructed.joins(:deck).where("constructeds.created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(oppclass: combo[1], win: true, 'decks.race' => combo[0]).count
			totalwins = totalwins + Constructed.joins(:deck).where("constructeds.created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(oppclass: combo[0], win: false, 'decks.race' => combo[1]).count

			totalgames = Constructed.joins(:deck).where("constructeds.created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(oppclass: combo[0], 'decks.race' => combo[1]).count + Constructed.joins(:deck).where("constructeds.created_at between ? and ?", Time.at(1388534400).to_datetime, Date.current.end_of_day).where(oppclass: combo[1], 'decks.race' => combo[0]).count

			@conrate << [ combo[0], [combo[1], (totalwins.to_f / totalgames)]]
		end

		# Arena Runs Data
		@arenaRuns = Array.new
		classes.each do |c|
			runCount = Array.new(13,0)
			totGames = ArenaRun.where(userclass: c).where("created_at between ? and ?", Time.at(1389830400).to_datetime, Date.current.end_of_day).count
			ArenaRun.where(userclass: c).where("created_at between ? and ?", Time.at(1389830400).to_datetime, Date.current.end_of_day).each do |ar|
				runCount[ar.arenas.count] += 1 unless ar.arenas.count > 12
			end
			runPercent = runCount.map { |e| e.to_f/totGames }
			@arenaRuns << [c, runCount, runPercent]
		end

		render :layout=> 'fullpage'
	end

	def decreport
		render :layout=> 'fullpage'
	end

	def novreport

		# # Determine Arena Class Win Rates
		# 	classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
		# 	@classarenarate = Hash.new
		# 	@arenatot = Hash.new
		# 	classes.each do |c|
		# 		totalwins = 0
		# 		totalgames = 0
		# 		totalwins = Arena.where(:userclass => c, :win => true).count + Arena.where(:oppclass => c, :win => false).count
		# 		totalgames = Arena.where(:userclass => c).count + Arena.where(:oppclass => c).count
		# 		@classarenarate[c] = (totalwins.to_f / totalgames)
		# 		@arenatot[c] = totalgames

		# 	end
		# 	@classarenarate = @classarenarate.sort_by { |name, winsrate| winsrate }.reverse

		# 	# Determine Constructed Class Win Rates

		# 	@classconrate = Hash.new
		# 	@contot = Hash.new
		# 	classes.each do |c|
		# 		totalwins = 0
		# 		totalgames = 0
		# 		totalwins = Constructed.joins(:deck).where(win: true, 'decks.race' => c).count
		# 		totalwins = totalwins + Constructed.where(oppclass: c, win: false).count
		# 		totalgames = Constructed.joins(:deck).where('decks.race' => c).count + Constructed.where(oppclass: c).count

		# 		@classconrate[c] = (totalwins.to_f / totalgames)
		# 		@contot[c] = totalgames
		# 	end
		# 	@classconrate = @classconrate.sort_by { |name, winsrate| winsrate }.reverse

		# 	# Most Played

		# 	@conclassnum = Hash.new
		# 	classes.each do |a|
		# 		@conclassnum[a] = @arenatot[a] + @contot[a]
		# 	end

		# 	# Determine Arena Class Win Rates
		# 	classcombos = classes.combination(2).to_a
		# 	@userarenarate = Hash.new
		# 	@totarenagames = Hash.new
		# 	classcombos.each do |combo|
		# 		totalwins = 0
		# 		totalgames = 0
		# 		totalwins = Arena.where(userclass: combo[0], oppclass: combo[1], win: true).count + Arena.where(userclass: combo[1], oppclass: combo[0], win: false).count
		# 		totalgames = Arena.where(userclass: combo[0], oppclass: combo[1]).count + Arena.where(userclass: combo[1], oppclass: combo[0]).count
		# 		@userarenarate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
		# 		@totarenagames["#{combo[0]} #{combo[1]}"] = totalgames
		# 	end

		# 	# Determine Constructed Class Win Rates
		# 	@conrate = Hash.new
		# 	@totcongames = Hash.new
		# 	classcombos.each do |combo|
		# 		totalwins = 0
		# 		totalgames = 0

		# 		totalwins = Constructed.joins(:deck).where(oppclass: combo[1], win: true, 'decks.race' => combo[0]).count
		# 		totalwins = totalwins + Constructed.joins(:deck).where(oppclass: combo[0], win: false, 'decks.race' => combo[1]).count

		# 		totalgames = Constructed.joins(:deck).where(oppclass: combo[0], 'decks.race' => combo[1]).count + Constructed.joins(:deck).where(oppclass: combo[1], 'decks.race' => combo[0]).count

		# 		@conrate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
		# 		@totcongames["#{combo[0]} #{combo[1]}"] = totalgames
		# 	end

		# 	# Arena Graphs
		# 	@timearray = Array.new(9, 0)
		# 	(1..9).each do |i|
		# 		@timearray[i-1] = i
		# 	end
		# 	@winscon = Hash.new
		# 	@winsarena = Hash.new
		# 	classes.each do |c|
		# 		@winsarena[c] = cularenagames(c, 9)
		# 		@winscon[c] = culcongames(c, 9)
		# 	end


		render :layout=> 'fullpage'
	end

	private

		def cularenagames(race, days1)
			wins = Array.new(days1, 0)
			wins[0] = 0
			(1..days1).each do |i|
				wins[i] = Arena.where(userclass: race, win: true).where(:created_at => i.days.ago.beginning_of_day..i.days.ago.end_of_day).count + Arena.where(oppclass: race, win: false).where(:created_at => i.days.ago.beginning_of_day..i.days.ago.end_of_day).count
			end
			return wins
		end

		def culcongames(race, days1)
			wins = Array.new(days1, 0)
			wins[0] = 0
			(1..days1).each do |i|
				wins[i] = Constructed.joins(:deck).where(win: true, 'decks.race' => race).where(:created_at => i.days.ago.beginning_of_day..i.days.ago.end_of_day).count + Constructed.where(oppclass: race, win: false).where(:created_at => i.days.ago.beginning_of_day..i.days.ago.end_of_day).count
			end
			return wins
		end

		def create_guest_user
			u = User.create(:email => "guest_#{Time.now.to_i}#{rand(99)}@example.com", :password => "demouser", :guest => true)
			u.save!(:validate => false)
			session[:guest_user_id] = u.id

			u
		end
end
