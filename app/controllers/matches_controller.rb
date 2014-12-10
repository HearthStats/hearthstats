class MatchesController < ApplicationController
  before_filter :authenticate_user!, except: :show

  # GET /matches/new
  # GET /matches/new.json
  def new
    @match = Match.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /matches/1/edit
  def edit
    @match = Match.find(params[:id])
  end

  # POST /matches
  # POST /matches.json
  def create
    @match = Match.new(params[:match])

    respond_to do |format|
      if @match.save
        format.html { redirect_to @match, notice: 'Match was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /matches/1
  # PUT /matches/1.json
  def update
    @match = Match.find(params[:id])

    respond_to do |format|
      if @match.update_attributes(params[:match])
        format.html { redirect_to @match, notice: 'Match was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
    @match = Match.find(params[:id])
    @match.destroy

    respond_to do |format|
      format.html { redirect_to request.referer, notice: 'Match was successfully deleted.' }
      format.js
    end
  end

  def show
    @match = Match.find(params[:id])
    begin
      @turns = []
      @players = []
      match_json = JSON.load(open("https://s3-us-west-2.amazonaws.com/hearthstats/prem-logs/#{@match.user_id}/#{@match.id}"))
      @players[match_json["firstPlayer"]] = match_json["firstPlayerName"]
      @players[match_json["secondPlayer"]] = match_json["secondPlayerName"]
      match_json["turns"].each_with_index do |turn, turn_count|
        turn_actions = []
        turn["actions"].each do |action|
          turn_actions << action
        end
        @turns << turn_actions
      end

      @turns.shift
   rescue
   end
  end

  def delete_all
    @matches = Match.where(user_id: current_user.id)
    @matches.delete_all
    respond_to do |format|
      format.html { redirect_to constructeds_path , notice: 'All Matches Deleted!'}
    end
  end

end
