class ProfilesController < ApplicationController
  # before_filter :authenticate_subs!, only: :activities

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
    if params[:no_email].to_i == 1
      current_user.update_attribute(:no_email, true)
    else
      current_user.update_attribute(:no_email, false)
    end

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
    if @user.guest
      return redirect_to root_url, alert: "Guests profiles cannot be accessed"
    end

    matches = Match.where(user_id: @user.id)
    @userkey = @user.get_userkey
    @profile = @user.profile
    impressionist(@profile)

    @profiletitle = @profile.name.blank? ? "User" : @profile.name

    @recent_matches = matches.last(6).reverse

    # Overall win rates
    arena_matches = matches.where(mode_id: 1)
    @overallarena= get_win_rate(arena_matches, true)
    con_matches = matches.where(mode_id: 3)
    @overallcon = get_win_rate(con_matches, true)

    @conwins   = Match.winrate_per_day_cumulative(con_matches, 10)
    @arenawins = Match.winrate_per_day_cumulative(arena_matches, 10)

    # Determine Constructed Class Win Rates
    @classconrate = Array.new
    matches = con_matches.group(:klass_id)
    wins = matches.where(result_id: 1).count
    tot_games = matches.count
    wins.each_pair do |klass_id, win|
      @classconrate << [ (win.to_f/tot_games[klass_id] * 100).round(2), "#{Klass::LIST[klass_id]}<br/>#{tot_games[klass_id]} Games"]
    end

    # Determine Arena Class Win Rates
    @classarenarate = Array.new
    matches = arena_matches.group(:klass_id)
    wins = matches.where(result_id: 1).count
    tot_games = matches.count
    wins.each_pair do |klass_id, win|
      @classarenarate << [ (win.to_f/tot_games[klass_id] * 100).round(2), "#{Klass::LIST[klass_id]}<br/>#{tot_games[klass_id]} Games"]
    end

    # User's Highest Winning Decks
    @topdeck = Deck.bestuserdeck(@user.id)
    @decks = Deck.joins("LEFT OUTER JOIN unique_decks ON decks.unique_deck_id = unique_decks.id").where(user_id: @user.id, is_public: true)

  end

  def set_locale
    if current_user.try(:guest?) || current_user.nil?
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

  def activities
    @activities = PublicActivity::Activity.order("created_at DESC").
      where(owner_type: "User", owner_id: current_user).all
    respond_to do |format|
      format.html
    end
  end

  private

  def arena_class
  end
end
