namespace :dbf do
	desc "Add all vars such as mode, result, class and rank"
	task :init=> :environment do
		desc "Import MODES"
    MODES = ["Arena","Casual","Ranked","Friendly","Practice"]
    MODES.each do |m|
      Mode.new(name: m).save
      p m + " mode added."
    end
    p "Modes Module Complete"

    desc "Import RESULTS"
    RESULTS = ["Win", "Loss","Draw"]
    RESULTS.each do |m|
      MatchResult.new(result: m).save  
      p m + " result added."
    end

    desc "Import KLASSES"
    KLASSES = ["Druid","Hunter","Mage","Paladin",
               "Priest","Rogue","Shaman","Warlock","Warrior"]
    KLASSES.each do |m|
      Klass.new(name: m).save  
      p m + " class added."
    end

    desc "Import RANKS"
    RANKS = ["Innkeeper","The Black Knight","Molten Giant","Moutain Giant",
             "Sea Giatn","Ancient of War","Sunwalker", "Frostwolf Warlord",
             "Silver Hand Knight","Ogre Magi","Big Game Hunter",
             "Warsong Commander","Dread Corsair","Raid Leader",
             "Silvermoon Guardian","Questing Adventurer", "Tauren Warrior",
             "Sorcerer's Apprentice","Novice Engineer","Shieldbearer",
             "Southsea Deckhand", "Murloc Raider","Argent Squire",
             "Leper Gnome","Angry Chicken"]

    RANKS.each do |m|
      Rank.new(name: m).save  
      p m + " rank added."
    end
	end

	task :arena => :environment do
		arena_matches = Arena.all
		arena_matches.each do |am|
			puts u.email
		end
	end


end
