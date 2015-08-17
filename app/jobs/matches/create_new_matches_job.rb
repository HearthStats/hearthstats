module MatchJobs
  CreateNewMatchesJob = Struct.new(:matches_params, :deck, :user_id) do
    def perform
      current_time = Time.now.to_s(:db)
      new_matches_sql = matches_params.map do |match_params|
        match_params.symbolize_keys!
        parse_match_sql(match_params, deck.klass_id, user_id, current_time)
      end

      sql_statement = "INSERT INTO matches (`user_id`, `mode_id`, `klass_id`, `result_id`, `coin`, `oppclass_id`, `oppname`, `numturns`, `duration`, `notes`, `appsubmit`, `created_at`, `updated_at`) VALUES #{new_matches_sql.join(",")}"
      initial_id = Match.last ? Match.last.id : 1
      last_id =  ActiveRecord::Base.connection.insert sql_statement

      match_deck_sql = []
      match_rank_sql = []
      current_time = Time.now.to_s(:db)
      (initial_id..last_id).each_with_index do |match_id, i|
        match_deck_sql << "(#{match_id}, #{deck.id}, '#{current_time}', '#{current_time}')"

        match_params = matches_params[i]
        if match_params[:mode] == "Ranked"
          match_rank_sql << "(#{match_id}, #{match_params["ranklvl"].to_i || "NULL"}, '#{current_time}', '#{current_time}')"
        end
      end
      deck_statement = "INSERT INTO match_decks (`match_id`, `deck_id`, `created_at`, `updated_at`) VALUES #{match_deck_sql.join(",")}"
      rank_statement = "INSERT INTO match_ranks (`match_id`, `rank_id`, `created_at`, `updated_at`) VALUES #{match_rank_sql.join(",")}"
      ActiveRecord::Base.connection.insert deck_statement if !match_deck_sql.empty?
      ActiveRecord::Base.connection.insert rank_statement if !match_rank_sql.empty?
    end

    def parse_match_sql(params, klass_id, user_id, current_time)
      mode     = Mode::LIST.invert[params[:mode]]
      oppclass = Klass::LIST.invert[params[:oppclass]]
      result   = Match::RESULTS_LIST.invert[params[:result]]
      coin     = params[:coin] == "true"
      match_str = "(#{user_id},#{mode},#{klass_id},#{result},#{coin},#{oppclass},'#{params[:oppname] || 'NULL'}',#{params[:numturns] || 'NULL'},#{params[:duration] || 'NULL'},'#{params[:notes] || 'NULL'}',true,'#{current_time}','#{current_time}')"

      match_str
    end

    def max_run_time
      120 # seconds
    end

    def queue_name
      'multicreate_queue'
    end
  end
end
