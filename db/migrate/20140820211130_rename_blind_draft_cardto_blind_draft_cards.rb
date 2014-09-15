class RenameBlindDraftCardtoBlindDraftCards < ActiveRecord::Migration
  def change
    rename_table :blind_draft_card, :blind_draft_cards
  end
end
