module MatchJobs
  CreateNewMatchesJob = Struct.new(:matches_params, :deck, :user_id) do
    def perform
      match_insert_sql = Match.generate_mass_insert_sql(matches_params, deck.klass_id, user_id)
      initial_id = Match.last ? Match.last.id : 1
      last_id =  ActiveRecord::Base.connection.insert match_insert_sql

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

    def max_run_time
      120 # seconds
    end

    def queue_name
      'multicreate_queue'
    end
  end
end
