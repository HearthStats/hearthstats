class DashboardsController < ApplicationController
  before_filter :authenticate_user!
  def race
  	@matches = Arena.where(user_id: current_user.id, userclass: params[:race])
  end

  def index
  	@arena = Arena.where(user_id: current_user.id).find(:all, :order => "id desc", :limit => 5)
  	@constructed = Constructed.where(user_id: current_user.id).find(:all, :order => "id desc", :limit => 5)
  	classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
  	@classwins = Hash.new
    @feed = Feedzirra::Feed.fetch_and_parse("http://mix.chimpfeedr.com/a87bd-Hearthstats")
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
  end
end