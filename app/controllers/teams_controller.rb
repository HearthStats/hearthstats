class TeamsController < ApplicationController
  # GET /teams
  # GET /teams.json
  def index
    redirect_to root_path, alert: "No new teams allowed right now" and return
    @teams = Team.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @teams }
    end
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @team = Team.find(params[:id])
    @members = @team.users

    # Get Win Rates
    matches = Match.where(user_id: @members, season_id: current_season)
    @arena_wr = get_win_rate(matches.where(mode_id: 1), true)
    @con_wr = get_win_rate(matches.where(mode_id: 3), true)

    # Get recent games
    @recent_entries = matches.last(10)
    recentgames(@members, 10)



    # Get decks from all team members
    @decks = Array.new
    @members.each do |m|
      @decks << m.decks
    end
    @decks.sort_by { |d| d.name }.reverse!
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @team }
    end
  end

  # GET /teams/new
  # GET /teams/new.json
  def new
    redirect_to root_path, alert: "No new teams allowed right now" and return
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @team }
    end
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(params[:team])

    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: 'Team was successfully created.' }
        format.json { render json: @team, status: :created, location: @team }
      else
        format.html { render action: "new" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.json
  def update
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
        format.html { redirect_to @team, notice: 'Team was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    redirect_to root_path, alert: "No new teams allowed right now" and return
    @team = Team.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to teams_url }
      format.json { head :no_content }
    end
  end
end
