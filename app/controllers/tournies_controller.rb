class TourniesController < ApplicationController

  before_filter :challongesignin

  def index
  end

  def signup
  end

  def past
  end

  def regtourny
    user = User.find(current_user.id)
    cid = Tourny.where(complete: false).last.challonge_id
    user.tourny_id = cid
    challonge = Challonge::Tournament.find(cid)
    ct = Challonge::Participant.create(:name => user.profile.bnetid, :tournament => challonge)
    if user.save and ct.errors.full_messages.blank?
			redirect_to root_path, notice: 'You entered the tournament!'
    else
    	redirect_to root_path, alert: "You were not added to the tournament. #{ct.errors.full_messages}"
    end
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
end
