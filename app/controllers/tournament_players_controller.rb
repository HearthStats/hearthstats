class TournamentPlayersController < ApplicationController
  def new
    @tournplayer = TournPlayer.new

    respond_to do |format|
      format.html  # new.html.erb
    end
  end

  def create
    @tournplayer = TournPlayer.new(params[:tournplayer])
    respond_to do |format|
    if @tournament.save
      format.html  { redirect_to(@tournplayer,
                    :notice => 'Tournament entry completed.') }
    else
      format.html  { render :action => "new" }
    end
  end
  end

  def show
  end

end
