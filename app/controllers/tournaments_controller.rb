class TournamentsController < ApplicationController
  def new
    @tournament = Tournament.new

    respond_to do |format|
      format.html  # new.html.erb
    end
  end

  def create
    @tournament = Tournament.new(params[:tournament])
    respond_to do |format|
      if @tournament.save
        format.html  { redirect_to(@tournament,
                      :notice => 'Tournament was successfully created.') }
      else
        format.html  { render :action => "new" }
      end
    end
  end

  def show
    @pairs = TournPair.where(tournament_id: 1)
    @num_columns = Math.log2(@pairs.length + 1).ceil
  end

end
