module MatchJobs
  CreateNewMatchesJob = Struct.new(:matches_params, :deck, :user_id) do
    def perform
      first_id = Match.connection.insert Match.generate_mass_insert_sql(matches_params, deck.klass_id, user_id)

      matches_params.each_with_index do |match_params, i|
        match_params[:id] = first_id + i
      end

      MatchDeck.connection.insert MatchDeck.generate_mass_insert_sql(matches_params, deck.id)

      ranked_params = matches_params.select do |match_params|
        match_params[:mode] == "Ranked" && match_params[:ranklvl]
      end

      unless ranked_params.empty?
        MatchRank.connection.insert MatchRank.generate_mass_insert_sql(ranked_params)
      end
    end

    def max_run_time
      120 # seconds
    end

    def queue_name
      'multicreate_queue'
    end
  end
end
