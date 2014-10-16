class TournPairsController < ApplicationController
  def show
    @tourn_pair = TournPair.find(params[:id])
    raise
    redirect_to @tourn_pair.tournament, notice: "Comment posted"
  end
end