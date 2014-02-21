namespace :dbf do
  KLASSES = {"Druid"=>1, "Hunter"=>2, "Mage"=>3, "Paladin"=>4, "Priest"=>5, "Rogue"=>6, "Shaman"=>7, "Warlock"=>8, "Warrior"=>9}
	desc "Add all vars such as mode, result, class and rank"
	task :init=> :environment do
		desc "Import MODES"
    MODES = ["Arena","Casual","Ranked","Friendly","Practice"]
    MODES.each do |m|
      Mode.new(name: m).save!
      p m + " mode added."
    end
    p "Modes Module Complete"

    desc "Import RESULTS"
    RESULTS = ["Win", "Loss","Draw"]
    RESULTS.each do |m|
      MatchResult.new(name: m).save!
      p m + " result added."
    end

    desc "Import KLASSES"
    KLASSES_H = ["Druid","Hunter","Mage","Paladin",
               "Priest","Rogue","Shaman","Warlock","Warrior"]
    KLASSES_H.each do |m|
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

    desc "Import TYPES"
    TYPES = ["Minion","Spell","Weapon"]
    TYPES.each do |m|
      Type.new(name: m).save
      p m + " type added."
    end

end

	task :constructed => :environment do
    con_matches = Constructed.all
    i = 0
    con_matches.each do |m|
      next if m.deck.nil?
      klass = KLASSES[m.deck.race]
      oppklass = KLASSES[m.oppclass]
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

      match = Match.new()
      match.created_at = m.created_at
      match.updated_at = m.updated_at
      match.user_id = m.user_id
      match.klass_id = klass
      match.oppclass_id = oppklass
      match.oppname = m.oppname
      match.mode_id = mode
      match.coin = !m.gofirst
      match.result_id = result
      match.notes = m.notes

      match.save!

      MatchDeck.new(
        :deck_id => m.deck_id,
        :match_id => match.id
      ).save!

      i += 1
      progress(i,con_matches.count)
    end
    p i.to_s + " constructed matches migrated."
	end

	task :arena => :environment do
		arena_matches = Arena.all
    i = 0
    error_array = Array.new

		arena_matches.each do |am|
      klass = KLASSES[am.userclass]
      oppklass = KLASSES[am.oppclass]

      if klass.nil?
        error_array << "user" + am.userclass.to_s
        next
      end

      if oppklass.nil?
        error_array << "opp" + am.userclass.to_s
        next
      end

      # Determine if win or loss
      if am.win
        result = 1
      else
        result = 2
      end
      m = Match.new()
      m.created_at = am.created_at
      m.updated_at = am.updated_at
      m.user_id = am.user_id
      m.klass_id = klass
      m.oppclass_id = oppklass
      m.oppname = am.oppname
      m.coin = !am.gofirst
      m.mode_id = 1
      m.result_id = result
      m.notes = am.notes
      m.save!

      mr = MatchRun.new()
      mr.match_id = m.id
      mr.arena_run_id = am.arena_run_id
      mr.save!

      i += 1
      progress(i, arena_matches.count )
		end
    p i.to_s + " arena matches migrated."
    p error_array
	end

	task :arenarun => :environment do
		i = 0
		allruns = ArenaRun.all
		allruns.each do |ar|
			if ar.arenas.first.nil?
				ar.delete!
				next
			end
			klass = KLASSES[ar.arenas.first.userclass]

      next if klass.nil?
      ar.klass_id = klass
      ar.save!
      i += 1

      progress(i, allruns.count)
    end
    p i.to_s + " arena runs changed"
	end

  task :deck => :environment do
    decks = Deck.all
    error_array = Array.new
    i = 0
    decks.each do |d|
      klass = KLASSES[d.race]

      if klass.nil?
        error_array << d.race.to_s
        next
      end

      d.klass_id = klass

      d.save!
      i += 1
      progress(i, decks.count)
    end
    p i.to_s + " decks changed"
  end

 	task :test => :environment do
 		Constructed.last(500).each_with_index do |ma, i|
      p KLASSES[ma.deck.race]
 			progress(i,500)
 		end
 	end

  def progress(completed,total)
    percent = ((completed / total.to_f) * 100).round
    print percent.to_s + "%"
    print "\r"

  end

end
