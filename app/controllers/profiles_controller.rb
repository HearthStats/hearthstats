class ProfilesController < ApplicationController

  def index
    authenticate_user!
  	redirect_to "/profiles/#{current_user.id}"
  end

  def edit
    authenticate_user!
    @profile = User.find(params[:id]).profile
    if current_user.id != @profile.user_id
      redirect_to root_url, alert: 'You are not authorized to edit that.'
    end
  end

  def update
    @profile = User.find(current_user.id).profile

    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        format.html { redirect_to "/profiles/#{current_user.id}", notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @user = User.find(params[:id])
    @userkey = @user.get_userkey
    if @user.guest
    	return redirect_to root_url, alert: "Guests cannot access profiles"
    end

    if !current_user || !(current_user.id == @user.id)
      if @user.profile.private
        return redirect_to root_url, notice: "User's Profile is Private"
      end
    end

    if newuser?(@user.id)
	    if current_user.id == @user.id
	    	return redirect_to root_url, alert: "You must enter at least one game before your profile is active."
	    else
	    	return redirect_to root_url, alert: "User profile is not active."
	    end
	  end

  	@profile = @user.profile
    if (!@profile.name.nil? && !@profile.name.blank?)
      @profiletitle = @profile.name
    else
      @profiletitle = "User"
    end
  	recentgames(@user.id, 10)
  	@recent_entries = Profile.get_recent_games(@user.id)
  	impressionist(@profile)
  	# Determine Arena Class Win Rates
    classes = ['Druid' ,'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    @classarenarate = Array.new
    classes.each_with_index do |c,i|
      totalwins = 0
      totalgames = 0
      totalwins = Arena.where(:userclass => c, :win => true, :user_id => @user.id ).count
      totalgames = Arena.where(:userclass => c, :user_id => @user.id ).count
      if totalgames == 0
      	@classarenarate[i] = [0,"#{classes[i]}<br/>0 Games"]
      else
		    @classarenarate[i] = [((totalwins.to_f / totalgames)*100).round(2), "#{classes[i]}<br/>#{totalgames} Games"]
		  end
    end
    # @classarenarate = @classarenarate.sort_by { |name, winsrate| winsrate }.reverse

    # Determine Constructed Class Win Rates

    @classconrate = Array.new
    classes.each_with_index do |c,i|
      totalwins = 0
      totalgames = 0
      totalwins = Constructed.joins(:deck).where(win: true, 'decks.race' => c, :user_id => @user.id ).count
      totalgames = Constructed.joins(:deck).where('decks.race' => c, :user_id => @user.id ).count
      if totalgames == 0
      	@classconrate[i] = [0,"#{classes[i]}<br/>0 Games"]
      else
        @classconrate[i] = [((totalwins.to_f / totalgames)*100).round(2), "#{classes[i]}<br/>#{totalgames} Games"]
		  end
    end
    # @classconrate = @classconrate.sort_by { |name, winsrate| winsrate }.reverse

    # User's Highest Winning Decks
    decks = Deck.where(user_id: @user.id)
    @userdeckrates = Hash.new
    decks.each do |d|
      totalgames = d.constructeds.count
      if totalgames == 0
        @userdeckrates[d.name] = [d.race, -1, d.id]
      else
      	@userdeckrates[d.name] = [d.race, d.constructeds.where(win:true).count.to_f / totalgames, d.id]
      end
    end
    @userdeckrates = @userdeckrates.sort_by { |name, winsrate| winsrate[1] }.reverse
    # Overall win rates
    @overallarena = [Arena.where(user_id: @user.id, win: true).count, Arena.where(user_id: @user.id, win: false).count, Arena.where(user_id: @user.id).count]
    @overallcon = [Constructed.where(user_id: @user.id, win: true).count, Constructed.where(user_id: @user.id, win: false).count, Constructed.where(user_id: @user.id).count]

  end
end
