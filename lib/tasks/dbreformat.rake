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

	task :constructed => :environment do
    con_matches = Constructed.all
    con_matches.each do |m|
      klass = Klass.where(name: m.deck.race).first
      oppklass = Klass.where(name: m.oppclass).first
      # Determine if win or loss
      if m.win
        result = 1
      else
        result = 2
      end
      # Determine if ranked or casual
      if m.rank == "Casual"
        mode = 2
      else
        mode = 3
      end
      match = Match.new(
        :created_at => m.created_at,
        :updated_at => m.updated_at,
        :user_id => m.user_id,
        :class_id => klass.id,
        :oppclass_id => oppklass.id,
        :oppname => m.oppname,
        :mode_id => mode,
        :result_id => result,
        :notes => m.notes

      ).save
      
      MatchDeck.new(
        :deck_id => m.deck_id,
        :match_id => match.id
      ).save

    end
	end

	task :arena => :environment do
		arena_matches = Arena.all
		arena_matches.each do |am|
			puts u.email
		end
	end


end
