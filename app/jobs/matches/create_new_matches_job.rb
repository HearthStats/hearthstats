module MatchJobs
  CreateNewMatchesJob = Struct.new(:matches_params, :deck, :user_id) do
    def perform
      new_matches = []
      response = []
      user_id = deck.user_id if user_id.nil?
      matches_params.each do |match_params|
        new_matches << parse_match_sql(match_params, deck.klass_id, user_id)
      end
      sql_statement = "INSERT INTO matches (`user_id`, `mode_id`, `klass_id`, `result_id`, `coin`, `oppclass_id`, `oppname`, `numturns`, `duration`, `notes`, `appsubmit`, `created_at`, `updated_at`) VALUES #{new_matches.join(",")}"
      initial_id = Match.last ? Match.last.id : 1
      last_id =  ActiveRecord::Base.connection.insert sql_statement
      match_deck_sql = []
      match_rank_sql = []
      current_time = Time.now.to_s(:db)
      (initial_id..last_id).each_with_index do |match_id, i|
        match_deck_sql << "(#{match_id}, #{deck.id},'#{current_time}', '#{current_time}')"
        # MatchDeck.create(match_id: match_id, deck_id: deck.id)
        if matches_params[i]['mode'] == "Ranked"
          match_rank_sql << "(#{match_id}, #{matches_params[i]["ranklvl"].to_i || 'NULL'}, '#{current_time}', '#{current_time}')"
          # MatchRank.create(match_id: match_id, rank_id: _req[:match][i]["ranklvl"].to_i)
        end
      end
      deck_statement = "INSERT INTO match_decks (`match_id`, `deck_id`, `created_at`,`updated_at`) VALUES #{match_deck_sql.join(",")}"
      rank_statement = "INSERT INTO match_ranks (`match_id`, `rank_id`, `created_at`,`updated_at`) VALUES #{match_rank_sql.join(",")}"
      ActiveRecord::Base.connection.insert deck_statement if !match_deck_sql.empty?
      ActiveRecord::Base.connection.insert rank_statement if !match_rank_sql.empty?
    end

    def parse_match_sql(_params, klass_id, user_id)
      _params = _params.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      # Parse params to get variables
      mode     = Mode::LIST.invert[_params[:mode]] || 'NULL'
      oppclass = Klass::LIST.invert[_params[:oppclass]] || 'NULL'
      result   = Match::RESULTS_LIST.invert[_params[:result]] || 'NULL'
      coin     = _params[:coin] == "true"
      match_str = "(#{user_id},#{mode},#{klass_id},#{result},#{coin},#{oppclass},'#{_params[:oppname] || 'NULL'}',#{_params[:numturns] || 'NULL'},#{_params[:duration] || 'NULL'},'#{_params[:notes] || 'NULL'}',true,'#{Time.now.to_s(:db)}','#{Time.now.to_s(:db)}')"

      match_str
    end

    def max_run_time
      120 # seconds
    end

    def queue_name
      'multcreate_queue'
    end
  end
end
