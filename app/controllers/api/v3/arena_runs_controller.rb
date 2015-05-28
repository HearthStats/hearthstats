class Api::V3::ArenaRunsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_req, except: [:show, :end]
  respond_to :json

  def show
    # Required params:
    # None, just app key
    begin
      last_arena_run = Hash.new
      games = Hash.new

      user = current_user
      last_run = ArenaRun.where(user_id: user.id).last
      last_run.matches.each_with_index do |game, i|
        games[i+1] = {
          oppclass_id: game.oppclass_id,
          result_id:   game.result_id,
          coin:        game.coin
        }
      end
      last_arena_run = {
        klass_id: last_run.klass_id,
        matches:  games
      }
    rescue
      api_response = {
        status:  "error",
        message: "Error getting last arena run games"
      }
    else
      api_response = {
        status: "success",
        data:   last_arena_run
      }
    end
    render json: api_response
  end

  def new
    # Required params:
    # params[:class], params[:cards]

    userclass_id = Klass::LIST.invert[@req[:class]]
    if userclass_id.nil?
      return render json: {
        status:  "fail",
        message: "Unknown user class."
      }
    end
    existing_runs = ArenaRun.where(user_id: current_user.id, complete: false)
    existing_runs.update_all(complete: true)
    arenarun = ArenaRun.new
    arenarun.user_id = current_user.id
    arenarun.klass_id = userclass_id

    if arenarun.save!
      deck = Deck.create(
                  name: "Arena##{arenarun.id}",
                  klass_id: userclass_id,
                  cardstring: Deck.hdt_parse(@req[:cards]),
                  user_id: current_user.id,
                  archived: true,
                  deck_type_id: 2
                )
      arenarun.update_attribute(:deck_id, deck.id)
      render json: {
        status: "success",
        data:   arenarun
      }
    else
      render json: {
        status:  "fail",
        message: arenarun.errors.full_messages
      }
    end
  end

  def end
    # Required params:
    # None, just app key
    # Optional params:
    # :notes, :gold, :dust

    user = current_user

    arena_run = ArenaRun.where(user_id: user.id, complete: false).last
    if arena_run.nil?
      render json: {
        status:  "error",
        message: "No Active Arena Run"
      }
      return
    end
    arena_run.complete = true

    if arena_run.save!
      render json: {
        status: "success",
        data:   arena_run
      }
    else
      render json: {
        status:  "fail",
        message: arenarun.errors.full_messages
      }
    end
  end

end
