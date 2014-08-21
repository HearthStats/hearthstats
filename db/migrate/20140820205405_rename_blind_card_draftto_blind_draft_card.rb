class RenameBlindCardDrafttoBlindDraftCard < ActiveRecord::Migration
  def up
    rename_table :blind_card_draft, :blind_draft_card
  end

  def down
  end
end
