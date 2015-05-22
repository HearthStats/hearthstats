class Api::Stats::ConstructedsController < ApplicationController
  respond_to :json

  def class_wr
    classconrate = Rails.cache.fetch('api#stats#class_wr', expires_in: 5.seconds) do
      con_matches = Match.where(mode_id: 3).last(1000)
      classconrate = [["Class", "Winrate", { role: 'style' }]]
      grouped_matches = con_matches.group_by{|m| m.klass_id}
      wins = {}
      tot_games = {}
      grouped_matches.each do |klass_id, matches|
        win_count = matches.select{|m| m.result_id == 1}.count
        wins[klass_id] = win_count
        tot_games[klass_id] = matches.count
      end
      wins.each_pair do |klass_id, win|
        classconrate << [ Klass::LIST[klass_id], (win.to_f/tot_games[klass_id] * 100).round(2), Klass::COLORS[klass_id]]
      end

      classconrate.sort_by {|class_name, wr| class_name }
    end
    
    render json: classconrate
  end


  def global_wr
    wr = Rails.cache.fetch('api#stats#global_wr', expires_in: 5.seconds) do
      get_array_wr(Match.where(mode_id: 3).last(100))
    end
    render json: wr
  end

  def list
    @user = User.where(userkey: params[:userkey])[0]
    render json: @user.matches.where(mode_id: [2,3])
  end

  def new
    render json: { status: "fail", message: "Please update your uploader."}
  end
end
