class MatchRank < ActiveRecord::Base
  attr_accessible :rank_id, :match_id, :legendary

  ### ASSOCIATIONS:

  belongs_to :rank
  belongs_to :match


  def self.generate_mass_insert_sql(matches_params)
    current_time = Time.now.to_s(:db)
    new_match_decks_sql = matches_params.map do |match_params|
      self.sanitize_sql_array(['(?,?,?,?)',
        match_params[:id], match_params[:ranklvl].to_i, current_time, current_time])
    end

    return <<-SQL
INSERT INTO match_ranks (`match_id`, `rank_id`, `created_at`, `updated_at`)
VALUES #{new_match_decks_sql.join(",")}
    SQL
  end

end
