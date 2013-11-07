class ProfilesController < ApplicationController
  def index
  	@user = current_user
  end

  def edit
  end

  def show
  	@user = User.find(params[:id])
  	@profile = @user.profile
  	recentgames(@user.id, 60)

  	# Determine Arena Class Win Rates
    classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    @classarenarate = Hash.new
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = Arena.where(:userclass => c, :win => true, :user_id => @user.id ).count + Arena.where(:oppclass => c, :win => false, :user_id => @user.id ).count
      totalgames = Arena.where(:userclass => c, :user_id => @user.id ).count + Arena.where(:oppclass => c, :user_id => @user.id ).count
      if totalgames == 0
      	@classarenarate[c] = -1
      else
	    @classarenarate[c] = (totalwins.to_f / totalgames)
	  end

    end
    @classarenarate = @classarenarate.sort_by { |name, winsrate| winsrate }.reverse

    # Determine Constructed Class Win Rates

    @classconrate = Hash.new
    classes.each do |c|
      totalwins = 0
      totalgames = 0
      totalwins = Constructed.joins(:deck).where(win: true, 'decks.race' => c, :user_id => @user.id ).count
      totalwins = totalwins + Constructed.joins(:deck).where(oppclass: c, win: false, :user_id => @user.id ).count
      totalgames = Constructed.joins(:deck).where('decks.race' => c, :user_id => @user.id ).count + Constructed.joins(:deck).where(oppclass: c, :user_id => @user.id ).count
      if totalgames == 0
      	@classconrate[c] = -1
      else
	    @classconrate[c] = (totalwins.to_f / totalgames)
	  end
      
    end
    @classconrate = @classconrate.sort_by { |name, winsrate| winsrate }.reverse

    # User's Highest Winning Decks
    decks = Deck.where(user_id: @user.id)
    @userdeckrates = Hash.new
    decks.each do |d|
    	@userdeckrates[d.name] = [d.race, d.wins.to_f / d.loses]
    end
    @userdeckrates = @userdeckrates.sort_by { |name, winsrate| winsrate }.reverse

  	respond_to do |format|
      format.html # show.html.erb
    end
  end
end
