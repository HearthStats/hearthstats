class MatchDeck < ActiveRecord::Base
  attr_accessible :deck_id, :match_id, :deck_version_id

  ### ASSOCIATIONS:

  belongs_to :deck
  belongs_to :match, dependent: :destroy

  ### CALLBACKS:

  # before_save :set_unique_deck_and_version
  after_create :update_deck_user_stats


  def self.generate_mass_insert_sql(matches_params, deck_id)
    current_time = Time.now.to_s(:db)
    new_match_decks_sql = matches_params.map do |match_params|
      self.sanitize_sql_array(['(?,?,?,?)',
        match_params[:id], deck_id, current_time, current_time])
    end

    return <<-SQL
INSERT INTO match_decks (`match_id`, `deck_id`, `created_at`, `updated_at`)
VALUES #{new_match_decks_sql.join(",")}
    SQL
  end

  ### INSTANCE METHODS:

  def set_unique_deck_and_version
    if !self.deck.nil? && !self.deck.unique_deck.nil?
      self.match.unique_deck = self.deck.unique_deck
      self.match.save
    end
  end

  def update_deck_user_stats
    #update personal stats
    deck.update_user_stats!
  end

end
