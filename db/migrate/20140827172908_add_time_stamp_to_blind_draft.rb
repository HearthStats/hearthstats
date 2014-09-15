class AddTimeStampToBlindDraft < ActiveRecord::Migration
  def change
    add_timestamps :blind_draft_cards
    add_timestamps :blind_drafts
  end
end
