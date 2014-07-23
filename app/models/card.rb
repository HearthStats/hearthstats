class Card < ActiveRecord::Base
  attr_accessible :name, :hearthhead_id, :description, :card_set_id, 
    :rarity_id, :type_id, :klass_id, :race_id, :mana, :health, :attack, 
    :collectible, :race_id, :blizz_id
    
  ### ASSOCIATIONS:
  
  belongs_to :klass
  belongs_to :card_set
  belongs_to :type
  
  has_many :unique_decks, through: :unique_deck_card
  has_many :unique_deck_card
  
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
