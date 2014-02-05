class RenameTables < ActiveRecord::Migration
  def change
    rename_table :matchranks, :match_ranks
    rename_table :matchresults, :match_results
    rename_table :matchruns, :match_runs
    rename_table :matchdecks, :match_decks
  end
end
