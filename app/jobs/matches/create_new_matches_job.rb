module MatchJobs
  CreateNewMatchesJob = Struct.new(:matches_params, :deck_id, :klass_id, :user_id) do
    def perform
      Match.mass_import_new_matches(matches_params, deck_id, klass_id, user_id)
    end

    def max_run_time
      120 # seconds
    end

    def queue_name
      'multicreate_queue'
    end
  end
end
