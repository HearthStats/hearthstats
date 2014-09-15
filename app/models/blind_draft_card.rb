class BlindDraftCard < ActiveRecord::Base
  belongs_to :user
  belongs_to :card
  belongs_to :blind_draft, dependent: :destroy
  
  attr_accessible :user_id, :card_id, :blind_draft_id
end