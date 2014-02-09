class Card < ActiveRecord::Base
  attr_accessible :name, :hearthhead_id, :description, :set_id, 
    :rarity_id, :type_id, :klass_id, :race_id, :mana, :health, :attack, 
    :collectible, :race_id
    
  belongs_to :klass
  belongs_to :set
  belongs_to :type
  
  def getImageUrl
    return "https://s3-us-west-2.amazonaws.com/hearthstats/cards/" + name.parameterize + ".png" 
    
  end
end
