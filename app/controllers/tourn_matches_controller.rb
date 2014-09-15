class TournMatchesController < ApplicationController

  def new
    @tourn_match = TournMatch.new
    pair = TournPair.find(params[:pair_id])
    @tournament = Tournament.find(params[:t_id])

    if params[:pos] == 0
      @name = pair.p2_name
      @p2 = TournUser.find(pair.p2_id)
      @decks = TournDeck.where(tourn_user_id: @p2.id)
    else
      @name = pair.p1_name
      @p1 = TournUser.find(pair.p1_id)
      @decks = TournDeck.where(tourn_user_id: @p1.id)
    end
  end

  def create
  end

end