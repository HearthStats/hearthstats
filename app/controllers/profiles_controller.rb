class ProfilesController < ApplicationController
  before_filter :authenticate_subs!, only: :activities

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

    matches = Match.where({user_id: @user.id, season_id: current_season}).all
    @userkey = @user.get_userkey
    @profile = @user.profile
    impressionist(@profile)

    @profiletitle = @profile.name.blank? ? "User" : @profile.name

    @recent_matches = matches.last(6).reverse

    # Overall win rates
    arena_matches = matches.select {|match| match.mode_id == 1}
    @overallarena= get_array_wr(arena_matches, true)
    con_matches = matches.select {|match| match.mode_id == 3}
    @overallcon = get_array_wr(con_matches, true)

    @conwins   = Match.winrate_per_day_cumulative(con_matches, 10)
    @arenawins = Match.winrate_per_day_cumulative(arena_matches, 10)

    # Determine Constructed Class Win Rates
    @classconrate = Array.new
    klass_matches = con_matches.group_by {|m| m.klass_id}
    klass_matches.each do |klass_id, klass_m|
      wins = klass_m.select {|m| m.result_id == 1}.count
      tot = klass_m.count

      wr = (wins.to_f/tot * 100 ).round(2)

      @classconrate << [wr, "#{Klass::LIST[klass_id]}<br/>#{tot} Games", klass_id]
    end

    # Determine Arena Class Win Rates
    @classarenarate = Array.new
    klass_matches = arena_matches.group_by {|m| m.klass_id}
    klass_matches.each do |klass_id, klass_m|
      wins = klass_m.select {|m| m.result_id == 1}.count
      tot = klass_m.count

      wr = (wins.to_f/tot * 100 ).round(2)

      @classarenarate << [wr, "#{Klass::LIST[klass_id]}<br/>#{tot} Games", klass_id]
    end

    # User's Highest Winning Decks
    topdeck_id = Rails.cache.fetch("topdeck-#{@user.id}", expires_in: 1.day) do
      deck = Deck.bestuserdeck(@user.id)
      deck.id if deck
    end
    @topdeck = Deck.find(topdeck_id) if topdeck_id
    @decks = Deck.joins("LEFT OUTER JOIN unique_decks ON decks.unique_deck_id = unique_decks.id").where(user_id: @user.id, is_public: true).all

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

end
