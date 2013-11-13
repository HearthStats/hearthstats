class WelcomeController < ApplicationController
	def index
		render :layout=>false
	end

	def novreport

	# Determine Arena Class Win Rates
		classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
		@classarenarate = Hash.new
		@arenatot = Hash.new
		classes.each do |c|
			totalwins = 0
			totalgames = 0
			totalwins = Arena.where(:userclass => c, :win => true).count + Arena.where(:oppclass => c, :win => false).count
			totalgames = Arena.where(:userclass => c).count + Arena.where(:oppclass => c).count
			@classarenarate[c] = (totalwins.to_f / totalgames)
			@arenatot[c] = totalgames

		end
		@classarenarate = @classarenarate.sort_by { |name, winsrate| winsrate }.reverse

		# Determine Constructed Class Win Rates

		@classconrate = Hash.new
		@contot = Hash.new
		classes.each do |c|
			totalwins = 0
			totalgames = 0
			totalwins = Constructed.joins(:deck).where(win: true, 'decks.race' => c).count
			totalwins = totalwins + Constructed.joins(:deck).where(oppclass: c, win: false).count
			totalgames = Constructed.joins(:deck).where('decks.race' => c).count + Constructed.joins(:deck).where(oppclass: c).count
			
			@classconrate[c] = (totalwins.to_f / totalgames)
			@contot[c] = totalgames
		end
		@classconrate = @classconrate.sort_by { |name, winsrate| winsrate }.reverse
	
		# Most Played

		@conclassnum = Hash.new
		classes.each do |a|
			@conclassnum[a] = @arenatot[a] + @contot[a]
		end

		# Determine Arena Class Win Rates
		classcombos = classes.combination(2).to_a
		@userarenarate = Hash.new
		@totarenagames = Hash.new
		classcombos.each do |combo|
			totalwins = 0
			totalgames = 0
			totalwins = Arena.where(userclass: combo[0], oppclass: combo[1], win: true).count + Arena.where(userclass: combo[1], oppclass: combo[0], win: false).count
			totalgames = Arena.where(userclass: combo[0], oppclass: combo[1]).count + Arena.where(userclass: combo[1], oppclass: combo[0]).count
			@userarenarate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
			@totarenagames["#{combo[0]} #{combo[1]}"] = totalgames
		end

		# Determine Constructed Class Win Rates
		@conrate = Hash.new
		@totcongames = Hash.new
		classcombos.each do |combo|
			totalwins = 0
			totalgames = 0

			totalwins = Constructed.joins(:deck).where(oppclass: combo[0], win: true, 'decks.race' => combo[1]).count
			totalwins = totalwins + Constructed.joins(:deck).where(oppclass: combo[1], win: false, 'decks.race' => combo[0]).count

			totalgames = Constructed.joins(:deck).where(oppclass: combo[0], 'decks.race' => combo[1]).count + Constructed.joins(:deck).where(oppclass: combo[1], 'decks.race' => combo[0]).count

			@conrate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
			@totcongames["#{combo[0]} #{combo[1]}"] = totalgames
		end

		# Arena Graphs
		@timearray = Array.new(9, 0)
		(1..9).each do |i|
			@timearray[i-1] = i
		end
		@winscon = Hash.new
		@winsarena = Hash.new
		classes.each do |c|
			@winsarena[c] = cularenagames(c, 9)
			@winscon[c] = culcongames(c, 9)
		end


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
end
