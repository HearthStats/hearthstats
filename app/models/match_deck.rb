class MatchDeck < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  attr_accessible :deck_id, :match_id, :deck_version_id

  def as_indexed_json(options={})
    match = self.match
    response = match.as_json
    response[:klass_name] = Klass::LIST[match.klass_id]
    response[:oppclass_name] = Klass::LIST[match.oppclass_id]
    response[:result_name] = Match::RESULTS_LIST[match.result_id]
    response[:mode_name] = Match::MODES_LIST[match.mode_id]
    response[:rank_name] = match.rank.try(:name)
    response[:deck_id] = match.deck.try(:id)

    return response
  end

  ### ASSOCIATIONS:

  belongs_to :deck
  belongs_to :match, dependent: :destroy

  ### CALLBACKS:

  # before_save :set_unique_deck_and_version
  after_create :update_deck_user_stats

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
