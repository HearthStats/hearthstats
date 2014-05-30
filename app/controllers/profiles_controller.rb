class ProfilesController < ApplicationController

  def index
    authenticate_user!
    redirect_to "/profiles/#{current_user.id}"
  end

  def edit
    authenticate_user!
    @profile = User.find(params[:id]).profile
    flash[:new_user] = true if current_user.sign_in_count == 1
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
    matches = Match.where(user_id: @user.id)
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
    classes = klasses_hash.map { |a| a[0] }
    load_recent_games(@user.id, 10)
    @recent_entries = Profile.get_recent_games(@user.id)
    impressionist(@profile)

    # Overall win rates
    arena_matches = matches.where(mode_id: 1)
    @overallarena= get_win_rate(arena_matches, true)
    con_matches = matches.where(mode_id: 3)
    @overallcon = get_win_rate(con_matches, true)

    # Determine Constructed Class Win Rates

    @classconrate = Array.new
    (1..Klass.all.count).each_with_index do |c,i|
      totalwins = 0
      totalgames = 0
      totalwins = matches.where( mode_id: 3,  klass_id: c, result_id: 1 ).count
      totalgames = matches.where( mode_id: 3, klass_id: c ).count
      if totalgames == 0
        @classconrate[i] = [0,"#{classes[i]}<br/>0 Games"]
      else
        @classconrate[i] = [((totalwins.to_f / totalgames)*100).round(2), "#{classes[i]}<br/>#{totalgames} Games"]
      end

    end

    arenaClass

    # User's Highest Winning Decks
    @topdeck = Deck.bestuserdeck(@user.id)
    @decks = Deck.joins("LEFT OUTER JOIN unique_decks ON decks.unique_deck_id = unique_decks.id").where(:user_id => @user.id, is_public: true)

  end

  def sig
    @user = User.find(params[:profile_id])
    matches = Match.where(user_id: @user.id, season_id: current_season)
    # Overall win rates
    arena_matches = matches.where(mode_id: 1)
    @overallarena= get_win_rate(arena_matches, true)
    con_matches = matches.where(mode_id: 3)
    @overallcon = get_win_rate(con_matches, true)

    render layout: false
  end

  def set_locale
    if current_user && current_user.guest?
      redirect_to root_path, alert: "Guests cannot change languages" and return
    end
    language = params[:locale]
    profile = current_user.profile
    profile.locale = language
    profile.save!
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  private

  def arenaClass
    classes = klasses_hash.map { |a| a[0] }
    # Determine Arena Class Win Rates
    @classarenarate = Array.new
    (1..Klass.all.count).each_with_index do |c,i|
      totalwins = 0
      totalgames = 0
      totalwins = Match.where( mode_id: 1, :klass_id => c, :result_id => 1, :user_id => @user.id ).count
      totalgames = Match.where( mode_id: 1, :klass_id => c, :user_id => @user.id ).count
      if totalgames == 0
        @classarenarate[i] = [0,"#{classes[i]}<br/>0 Games"]
      else
        @classarenarate[i] = [((totalwins.to_f / totalgames)*100).round(2), "#{classes[i]}<br/>#{totalgames} Games"]
      end
    end

  end
end
