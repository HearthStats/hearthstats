class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  def race
  	@matches = Arena.where(user_id: current_user.id, userclass: params[:race])
  end

  def index
    recentgames(current_user.id, 12)

  	# @constructed = Constructed.where(user_id: current_user.id).find(:all, :order => "id desc", :limit => 100)
  	
    # Fetch total wins for each class
   #  classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
  	# @classwins = Hash.new
  	# classes.each do |c|
  	# 	arenacount = Arena.where(:userclass => c, :win => true).count
  	# 	deckcount = Deck.where(:race => c)
  	# 	if deckcount.blank? || deckcount[0].wins.nil?
  	# 		temp2 = 0
  	# 	else
   #      temp2 = 0
   #      deckcount.each do |d|
   #        temp2 = temp2 + d.wins
   #      end
  	# 	end
  	# 	@classwins[c] = arenacount + temp2
  	# 	# instance_variable_set("@#{c}", temp)
  	# end
  	# @classwins = @classwins.sort_by { |name, wins| wins }.reverse

    # Determine Arena Class Win Rates
    classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    @classarenarate = Hash.new
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = Arena.where(:userclass => c, :win => true).count + Arena.where(:oppclass => c, :win => false).count
      totalgames = Arena.where(:userclass => c).count + Arena.where(:oppclass => c).count
      @classarenarate[c] = (totalwins.to_f / totalgames)

    end
    @classarenarate = @classarenarate.sort_by { |name, winsrate| winsrate }.reverse

    # Determine Constructed Class Win Rates

    @classconrate = Hash.new
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = Constructed.joins(:deck).where(win: true, 'decks.race' => c).count
      totalwins = totalwins + Constructed.joins(:deck).where(oppclass: c, win: false).count
      totalgames = Constructed.joins(:deck).where('decks.race' => c).count + Constructed.joins(:deck).where(oppclass: c).count
      
      @classconrate[c] = (totalwins.to_f / totalgames)
    end
    @classconrate = @classconrate.sort_by { |name, winsrate| winsrate }.reverse

    # 
  end

  def fullstats
    # Determine Arena Class Win Rates
    classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    @classwinrate = Hash.new
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = Arena.where(:userclass => c, :win => true).count + Arena.where(:oppclass => c, :win => false).count
      totalgames = Arena.where(:userclass => c).count + Arena.where(:oppclass => c).count
      @classwinrate[c] = (totalwins.to_f / totalgames)

    end
    @classwinrate = @classwinrate.sort_by { |name, winsrate| winsrate }.reverse

    # Determine Arena Class Win Rates
    classcombos = classes.combination(2).to_a
    @userarenarate = Hash.new
    classcombos.each do |combo|
      totalwins = 0
      totalgames = 0
      totalwins = Arena.where(userclass: combo[0], oppclass: combo[1], win: true).count + Arena.where(userclass: combo[1], oppclass: combo[0], win: false).count
      totalgames = Arena.where(userclass: combo[0], oppclass: combo[1]).count + Arena.where(userclass: combo[1], oppclass: combo[0]).count
      @userarenarate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
    end

    # Determine Arena Class Win Rates
    @conrate = Hash.new
    classcombos.each do |combo|
      totalwins = 0
      totalgames = 0

      totalwins = Constructed.joins(:deck).where(oppclass: combo[0], win: true, 'decks.race' => combo[1]).count
      totalwins = totalwins + Constructed.joins(:deck).where(oppclass: combo[1], win: false, 'decks.race' => combo[0]).count

      totalgames = Constructed.joins(:deck).where(oppclass: combo[0], 'decks.race' => combo[1]).count + Constructed.joins(:deck).where(oppclass: combo[1], 'decks.race' => combo[0]).count

      @conrate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
    end

  end


end