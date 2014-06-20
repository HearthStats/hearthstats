class Tourny < ActiveRecord::Base
  attr_accessible :challonge_id, :prize, :status, :winner_id, :title, :date, :desc, :user_decks_id, :pic_link
  has_many :users
end
