class Card < ActiveRecord::Base
  attr_accessible :name, :hearthhead_id, :description, :card_set,
                  :rarity_id, :type_name, :klass_id, :mana, :health, :attack,
                  :collectible, :blizz_id, :patch_id

  RARITY = {
    5 => "Legendary",
    4 => "Epic",
    3 => "Rare",
    2 => "Common",
    1 => "Free"
  }

  ### ASSOCIATIONS:

  belongs_to :klass

  has_many :unique_decks, through: :unique_deck_card
  has_many :unique_deck_card

  has_many :blind_drafts, through: :blind_draft_card
  has_many :blind_draft_card

  has_many :mechanics, through: :card_mechanic
  has_many :card_mechanic


  ### VALIDATIONS:

  validates :name, uniqueness: true, presence: true

  ### INSTANCE METHODS:

  def toJSONWithImage
     return to_json[0..-2] + ',"image":"' + getImageUrl + '"}'
  end

  def getImageUrl
    return "https://s3-us-west-2.amazonaws.com/hearthstats/cards/" + name.parameterize + ".png"
  end
end
