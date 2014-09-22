class TourniesController < ApplicationController

  # before_filter :challongesignin

  def index
    @tournies = Tourny.all.reverse
  end

  def show
    @tourny = Tourny.find(params[:id])

    params[:items] ||= 20

    @q = Deck.where(is_public: true).
              where(user_id: @tourny.user_decks_id).
              group(:unique_deck_id).
              joins(:unique_deck).
              includes(:unique_deck, user: :profile).
              ransack(params[:q])

    @decks = @q.result
    @decks = @decks.order("#{sort_by} #{direction}")
    @decks = @decks.paginate(page: params[:page], per_page: params[:items])

    if current_user
      unique_deck_ids = @decks.map(&:unique_deck_id)
      @user_decks = current_user.decks.where("unique_deck_id IN (?)", unique_deck_ids)
    end

  end

  def signup
    if params["region"] == "North America"
      tourn_id = 1
    elsif params["region"] == "Europe"
      tourn_id = 2
    end

    if TournUser.where(tournament_id: tourn_id).count > 120
      redirect_to '/league', alert: "Tournament full!" and return
    end

    if current_user.nil?
      redirect_to '/league', alert: "You need a Hearthstats account to sign up!" and return
    end

    tourn_user = TournUser.new(user_id: current_user.id, tournament_id: tourn_id)
    if tourn_user.save
      redirect_to '/league', notice: "Successfully signed up! Congrats!"
    else
      redirect_to '/league', alert: "Error signing up for the tournament"
    end
  end

  def past
  end

  def calendar
  end

  def regtourny
    # user = User.find(current_user.id)
    # cid = Tourny.where(complete: false).last.challonge_id
    # user.tourny_id = cid
    # challonge = Challonge::Tournament.find(cid)
    # ct = Challonge::Participant.create(name: user.profile.bnetid, tournament: challonge)
    # if user.save and ct.errors.full_messages.blank?
    #   redirect_to root_path, notice: 'You entered the tournament!'
    # else
    #   redirect_to root_path, alert: "You were not added to the tournament. #{ct.errors.full_messages}"
    # end
  end

  def new
    @tourny = Tourny.new
    @challonge = Challonge::Tournament.new
    respond_to  do |format|
      format.html
      format.json { render json: @tourny}
    end
  end

  def create
    @tourny = Tourny.new(params[:tourny])

    raise
    respond_to do |format|
      if @tourny.save
        format.html { redirect_to @tourny, notice: 'Tourny as successfully created.' }
        format.json { render json: @tourny, status: :created, location: @tourny }
      else
        format.html { render action: "new" }
        format.json { render json: @tourny.errors, status: :unprocessable_entity }
      end
    end
  end

  def createtourny
    t = Challonge::Tournament.new
    t.name = params[:name]
    t.url = params[:url]

    respond_to do |format|
      if t.save
        localtourny(t.id,params[:type])
        format.html { redirect_to root_path, notice: 'Tourny was successfully created.' }
      else
        flash[:notice] = t.errors.full_messages
        format.html { render action: "new" }
      end
    end
  end

  private

  def challongesignin
    Challonge::API.username = 'HearthStats'
    Challonge::API.key = 'K0A8CfyGghLAJXL8klGajpjk32LfTMuXqMOofpgS'
  end

  def localtourny(cid, status)
    tourny = Tourny.new
    tourny.challonge_id = cid
    tourny.status = status
    tourny.save
    if tourny.save
    else
      format.html { redirect_to root_path, alert: 'Local Tourny not saved!' }
    end
  end

  def sort_by
    return 'num_users' unless params[:sort]

    sort = (Deck.column_names + UniqueDeck.column_names).include?(params[:sort]) ? params[:sort] : 'num_users'
    sort = 'decks.created_at' if sort == 'created_at'
  end

  def direction
    %w{asc desc}.include?(params[:order]) ? params[:order] : 'desc'
  end
end
