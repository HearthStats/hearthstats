class WelcomeController < ApplicationController
	caches_action :marreport ,expires_in: 1.day
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


	def marreport
		matches = Match.where(season_id: current_season)
		# Determine match Class Win Rates
		@classesArray = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
		classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
		@classarenarate = Hash.new
		@arenatot = Hash.new
		mode_matches = matches.where(mode_id: 1)
		classes.each do |c|
			totalwins = 0
			totalgames = 0
			totalwins = mode_matches.where(:klass_id => klasses_hash[c], :result_id => 1).count + mode_matches.where(:oppclass_id => klasses_hash[c], :result_id => 2).count
			totalgames = mode_matches.where(:klass_id => klasses_hash[c]).count + mode_matches.where(:oppclass_id => klasses_hash[c]).count
			if totalgames == 0
				@classarenarate[c] = 0
			else
				@classarenarate[c] = (totalwins.to_f / totalgames)
			end
			@arenatot[c] = totalgames

		end
		@classarenarate = @classarenarate.sort_by { |name, winsrate| winsrate }.reverse

		# Determine mode_matches Class Win Rates

		@classconrate = Hash.new
		@contot = Hash.new
		mode_matches = matches.where(mode_id: 3)
		classes.each do |c|
			totalwins = 0
			totalgames = 0
			totalwins = mode_matches.where(result_id: 1, :klass_id => klasses_hash[c]).count
			totalwins = totalwins + mode_matches.where(oppclass_id: klasses_hash[c], result_id: 2).count
			totalgames = mode_matches.where(:klass_id => klasses_hash[c]).count + mode_matches.where(oppclass_id: klasses_hash[c]).count
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

		# Determine mode_matches Class Win Rates
		# classcombos = classes.combination(2).to_a
		classcombos = Array.new
		classes.each do |c|
			classes.each do |c2|
				classcombos << [c,c2]
			end
		end
		@userarenarate = Array.new
		@totarenagames = Hash.new
		mode_matches = matches.where(mode_id: 1)
		classcombos.each_with_index do |combo, i |
			totalwins = 0
			totalgames = 0
			totalwins = mode_matches.where(klass_id: klasses_hash[combo[0]], oppclass_id: klasses_hash[combo[1]], result_id: 1).count + mode_matches.where(klass_id: klasses_hash[combo[1]], oppclass_id: klasses_hash[combo[0]], result_id: 2).count
			totalgames = mode_matches.where(klass_id: klasses_hash[combo[0]], oppclass_id: klasses_hash[combo[1]],result_id: [1,2]).count + mode_matches.where(klass_id: klasses_hash[combo[1]], oppclass_id: klasses_hash[combo[0]],result_id: [1,2]).count
			@userarenarate << [ combo[0], [combo[1], (totalwins.to_f / totalgames)]]
		end
		# Determine mode_matches Class Win Rates
		@conrate = Array.new
		@totcongames = Hash.new
		mode_matches = matches.where(mode_id: 3)
		classcombos.each_with_index do |combo, i |
			totalwins = 0
			totalgames = 0

			totalwins = mode_matches.where(oppclass_id: klasses_hash[combo[1]], result_id: 1, klass_id: klasses_hash[combo[0]]).count
			totalwins = totalwins + mode_matches.where(oppclass_id: klasses_hash[combo[0]], result_id: 2, klass_id: klasses_hash[combo[1]]).count

			totalgames = mode_matches.where(oppclass_id: klasses_hash[combo[0]], klass_id: klasses_hash[combo[1]], result_id: [1,2]).count + mode_matches.where(oppclass_id: klasses_hash[combo[1]], klass_id: klasses_hash[combo[0]], result_id: [1,2]).count

			@conrate << [ combo[0], [combo[1], (totalwins.to_f / totalgames)]]
		end

		# mode_matches Runs Data
		@arenaRuns = Array.new
		classes.each_with_index do |c,i|
			runCount = Array.new(13,0)
			totGames = ArenaRun.where(klass_id: i+1).count
			ArenaRun.where(klass_id: i+1).each do |ar|
				runCount[ar.matches.count] += 1 unless ar.matches.count > 12
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

		# # Determine mode_matches Class Win Rates
		# 	classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
		# 	@classarenarate = Hash.new
		# 	@arenatot = Hash.new
		# 	classes.each do |c|
		# 		totalwins = 0
		# 		totalgames = 0
		# 		totalwins = mode_matches.where(:klass_id => c, :result_id => true).count + mode_matches.where(:oppclass_id => c, :result_id => false).count
		# 		totalgames = mode_matches.where(:klass_id => c).count + mode_matches.where(:oppclass_id => c).count
		# 		@classarenarate[c] = (totalwins.to_f / totalgames)
		# 		@arenatot[c] = totalgames

		# 	end
		# 	@classarenarate = @classarenarate.sort_by { |name, winsrate| winsrate }.reverse

		# 	# Determine mode_matches Class Win Rates

		# 	@classconrate = Hash.new
		# 	@contot = Hash.new
		# 	classes.each do |c|
		# 		totalwins = 0
		# 		totalgames = 0
		# 		totalwins = mode_matches.joins(:deck).where(result_id: true, 'decks.race' => c).count
		# 		totalwins = totalwins + mode_matches.where(oppclass_id: c, result_id: false).count
		# 		totalgames = mode_matches.joins(:deck).where('decks.race' => c).count + mode_matches.where(oppclass_id: c).count

		# 		@classconrate[c] = (totalwins.to_f / totalgames)
		# 		@contot[c] = totalgames
		# 	end
		# 	@classconrate = @classconrate.sort_by { |name, winsrate| winsrate }.reverse

		# 	# Most Played

		# 	@conclassnum = Hash.new
		# 	classes.each do |a|
		# 		@conclassnum[a] = @arenatot[a] + @contot[a]
		# 	end

		# 	# Determine mode_matches Class Win Rates
		# 	classcombos = classes.combination(2).to_a
		# 	@userarenarate = Hash.new
		# 	@totarenagames = Hash.new
		# 	classcombos.each do |combo|
		# 		totalwins = 0
		# 		totalgames = 0
		# 		totalwins = mode_matches.where(klass: combo[0], oppclass_id: combo[1], result_id: true).count + mode_matches.where(klass: combo[1], oppclass_id: combo[0], result_id: false).count
		# 		totalgames = mode_matches.where(klass: combo[0], oppclass_id: combo[1]).count + mode_matches.where(klass: combo[1], oppclass_id: combo[0]).count
		# 		@userarenarate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
		# 		@totarenagames["#{combo[0]} #{combo[1]}"] = totalgames
		# 	end

		# 	# Determine mode_matches Class Win Rates
		# 	@conrate = Hash.new
		# 	@totcongames = Hash.new
		# 	classcombos.each do |combo|
		# 		totalwins = 0
		# 		totalgames = 0

		# 		totalwins = mode_matches.joins(:deck).where(oppclass_id: combo[1], result_id: true, 'decks.race' => combo[0]).count
		# 		totalwins = totalwins + mode_matches.joins(:deck).where(oppclass_id: combo[0], result_id: false, 'decks.race' => combo[1]).count

		# 		totalgames = mode_matches.joins(:deck).where(oppclass_id: combo[0], 'decks.race' => combo[1]).count + mode_matches.joins(:deck).where(oppclass_id: combo[1], 'decks.race' => combo[0]).count

		# 		@conrate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
		# 		@totcongames["#{combo[0]} #{combo[1]}"] = totalgames
		# 	end

		# 	# mode_matches Graphs
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
				wins[i] = mode_matches.where(klass: race, result_id: true).where(:created_at => i.days.ago.beginning_of_day..i.days.ago.end_of_day).count + mode_matches.where(oppclass_id: race, result_id: false).where(:created_at => i.days.ago.beginning_of_day..i.days.ago.end_of_day).count
			end
			return wins
		end

		def culcongames(race, days1)
			wins = Array.new(days1, 0)
			wins[0] = 0
			(1..days1).each do |i|
				wins[i] = mode_matches.joins(:deck).where(result_id: true, 'decks.race' => race).where(:created_at => i.days.ago.beginning_of_day..i.days.ago.end_of_day).count + mode_matches.where(oppclass_id: race, result_id: false).where(:created_at => i.days.ago.beginning_of_day..i.days.ago.end_of_day).count
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
