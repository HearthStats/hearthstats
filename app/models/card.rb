class Card < ActiveRecord::Base
  attr_accessible :name, :hearthhead_id, :description, :set_id, 
    :rarity_id, :type_id, :class_id, :race_id, :mana, :health, :attack, 
    :collectible, :race_id
end