class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  def race
  	@matches = Arena.where(user_id: current_user.id, userclass: params[:race])
  end

  def index
    # Find recent games
  	@arena = Arena.where(user_id: current_user.id).find(:all, :order => "id desc", :limit => 5)
  	@constructed = Constructed.where(user_id: current_user.id).find(:all, :order => "id desc", :limit => 5)
  	
    # Fetch total wins for each class
    classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
  	@classwins = Hash.new
  	classes.each do |c|
  		arenacount = Arena.where(:userclass => c, :win => true).count
  		deckcount = Deck.where(:race => c)
  		if deckcount.blank? || deckcount[0].wins.nil?
  			temp2 = 0
  		else
        temp2 = 0
        deckcount.each do |d|
          temp2 = temp2 + d.wins
        end
  		end
  		@classwins[c] = arenacount + temp2
  		# instance_variable_set("@#{c}", temp)
  	end
  	@classwins = @classwins.sort_by { |name, wins| wins }.reverse

    # News feed for Heathstone news
    @feed = Feedzirra::Feed.fetch_and_parse("http://mix.chimpfeedr.com/a87bd-Hearthstats")

  end

  def fullstats
    # Determin Win Rates
    classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    @classwinrate = Hash.new
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = Arena.where(:userclass => c, :win => true).count + Arena.where(:oppclass => c, :win => false).count
      totalgames = totalwins + Arena.where(:userclass => c).count + Arena.where(:oppclass => c).count
      @classwinrate[c] = (totalwins.to_f / totalgames)

    end
    
  end


end