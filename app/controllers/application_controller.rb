class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper

  layout :layout
  before_filter :set_locale



  def opinio_after_create_path(resource)
  	resource.user.notify( "New Comment", "New comment on " + resource.class.name + " " + resource.name )
  	resource.is_a?(Opinio.model_name.constantize) ? resource.commentable : resource
	end

  def get_win_rate(matches, strOut = false )
    return 0 if matches.nil?
    wins = matches.where(result_id: 1).count.to_f
    tot_games = matches.count
    win_rate = wins / tot_games
    win_rate = "N/A" and return win_rate if win_rate.nan?
    win_rate = (win_rate*100).round(2)
		win_rate = win_rate.to_s + "%" if strOut

    win_rate
  end

  def default_url_options(options={})
    { :locale => I18n.locale }.merge options
  end

  helper_method :uploader_url, :get_win_rate, :public_url, :klasses_hash_2, :klasses_hash


  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # API Methods
  def validate_userkey
    userkey = User.where(userkey: params[:userkey])
    unless userkey.exists? && !params[:userkey].nil?
    	api_response = {status: "error", message: "User Key Error"}
    	render :json => api_response and return
    end
  end

  def get_user_api
    @user = User.where(userkey: params[:userkey])[0]
		@req = ActiveSupport::JSON.decode(request.body).symbolize_keys
  end

  def layout
    # only turn it off for login pages:
    is_a?(Devise::SessionsController) ? false : "application"
    # or turn layout off for every devise controller:
    !devise_controller? && "application"
  end

  def canedit(entry)
  	if current_user.id != entry.user_id
      redirect_to root_url, alert: 'You are not authorized to edit that.'
    end
  end

  def recentgames(userid, durlen)
    @arenawins = cularenagames(userid, durlen)
    @conwins = culcongames(userid, durlen)
  end

  def cularenagames(userid, days1)
    winrate = Array.new(days1, 0)
    (0..days1).each do |i|
      matches = Match.where( mode_id: 1, user_id: userid, season_id: current_season).where("created_at <= ?", i.days.ago.end_of_day)
      win = matches.where(result_id: 1).count
      tot = matches.count
      winrate[i] = [i.days.ago.beginning_of_day.to_i*1000,((win.to_f / tot)*100).round(2)]
    end

    return winrate
  end

  def culcongames(userid, days1)
    winrate = Array.new(days1, 0)
    (0..days1).each do |i|
      matches = Match.where( mode_id: 3, user_id: userid, season_id: current_season).where("created_at <= ?", i.days.ago.end_of_day)
      tot = matches.count
      win = matches.where(result_id: 1).count
      winrate[i] = [i.days.ago.beginning_of_day.to_i*1000,((win.to_f / tot)*100).round(2)]
	  end

	  return winrate
	end

  def recentgamesbyhr(userid, durlen)
    # Find games from 12 hours and before
    @timearray = Array.new(durlen, 0)
    (1..durlen).each do |i|
      @timearray[i-1] = i
    end

    @arenawins = Array.new(durlen, 0)
    arena = Arena.where(user_id: userid, win: true).where('created_at > ?', durlen.hours.ago)
    arena.each do |a|
      timebefore = ((Time.now - a.created_at)/1.hour).round
      if @arenawins[timebefore].nil?
        @arenawins[timebefore] = 0
      else
        @arenawins[timebefore] += 1
      end
    end

    @conwins = Array.new(durlen, 0)
    constructed = Constructed.where(user_id: userid, win: true).where('created_at > ?', durlen.hours.ago)
    constructed.each do |a|
      timebefore = ((Time.now - a.created_at)/1.hour).round
      if @conwins[timebefore].nil?
        @conwins[timebefore] = 0
      else
        @conwins[timebefore] += 1
      end
    end
    winrate[i] = [i.days.ago.beginning_of_day.to_i*1000,((win.to_f / tot)*100).round(2)]
    return winrate
  end

  def public_url(file)
    "http://hearthstats.net/" + file
  end

  def newuser?(userid)
  	user = User.find(userid)
  	games_count = Arena.where(user_id = user.id).count + Constructed.where(user_id = user.id).count
  	return true if games_count == 0

  	false
  end


end
