class Card < ActiveRecord::Base
  attr_accessible :name, :hearthhead_id, :description, :set_id, 
    :rarity_id, :type_id, :klass_id, :race_id, :mana, :health, :attack, 
    :collectible, :race_id
    
  belongs_to :klass
end