module MatchJobs
  CreateNewMatchesJob = Struct.new(:matches_params, :deck, :user_id) do
    def perform
      match_insert_sql = Match.generate_mass_insert_sql(matches_params, deck.klass_id, user_id)
      initial_id = Match.last ? Match.last.id : 0
      ActiveRecord::Base.connection.insert match_insert_sql

      matches_params.each_with_index do |match_params, i|
        match_params[:id] = initial_id + i + 1
      end

      match_deck_sql = MatchDeck.generate_mass_insert_sql(matches_params, deck.id)
      ranked_params = matches_params.select do |match_params|
        match_params[:mode] == "Ranked" && match_params[:ranklvl]
      end
      match_rank_sql = MatchRank.generate_mass_insert_sql(ranked_params)

      ActiveRecord::Base.connection.insert match_deck_sql
      ActiveRecord::Base.connection.insert match_rank_sql unless ranked_params.empty?
    end

    def max_run_time
      120 # seconds
    end

    def queue_name
      'multicreate_queue'
    end
  end
end
