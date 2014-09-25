class BlindDraft < ActiveRecord::Base
  attr_accessible :cardstring, :player1_id, :player2_id, :card_cap, :public

  ### ASSOCIATIONS:

  belongs_to :player1, class_name: 'User', foreign_key: 'player1_id'
  belongs_to :player2, class_name: 'User', foreign_key: 'player2_id'

  has_many :blind_draft_cards
  has_many :cards, through: :blind_draft_cards

  after_create :create_card_associations

  ### SCOPES:

  ### INSTANCE METHODS:

  def create_card_associations
    card_pool = Card.where(collectible: true, klass_id: nil)
                    .sample(self.card_cap)
    cardstring = card_pool.map { |card| card.id }.join(",")
    self.update_attribute(:cardstring, cardstring)
    card_pool.each do |card|
      BlindDraftCard.create(blind_draft_id: self.id, card_id: card.id)
    end
  end

  def player1
    User.find(player1_id)
  end

  def player2
    User.find(player2_id)
  end

  def player1_cards
    find_player_cards(self.player1_id)
  end

  def player2_cards
    find_player_cards(self.player2_id)
  end

  def find_player_cards(player_id)
    self.blind_draft_cards
        .where(blind_draft_cards: { user_id: player_id})
        .includes(:card)
  end

end
