class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  def race
  	@matches = Arena.where(user_id: current_user.id, userclass: params[:race])
  end

  def index
    # recentgamesbyhr(current_user.id, 12)
    recentgames(current_user.id, 10)

 		@globarena = ((Arena.where(win: true).count.to_f / Arena.count)*100).round
 		@globcon = ((Constructed.where(win: true).count.to_f / Constructed.count)*100).round
 		@topdeck = Deck.bestuserdeck(current_user.id)
 		@toparena = Arena.bestuserarena(current_user.id)
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

      totalwins = Constructed.joins(:deck).where(oppclass: combo[1], win: true, 'decks.race' => combo[0]).count
      totalwins = totalwins + Constructed.joins(:deck).where(oppclass: combo[0], win: false, 'decks.race' => combo[1]).count

      totalgames = Constructed.joins(:deck).where(oppclass: combo[0], 'decks.race' => combo[1]).count + Constructed.joins(:deck).where(oppclass: combo[1], 'decks.race' => combo[0]).count

      @conrate["#{combo[0]} #{combo[1]}"] = (totalwins.to_f / totalgames)
    end

    expires_in 4.hour, public: true
  end


end