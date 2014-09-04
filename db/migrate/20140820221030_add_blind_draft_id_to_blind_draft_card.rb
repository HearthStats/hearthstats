class AddBlindDraftIdToBlindDraftCard < ActiveRecord::Migration
  def change
    add_column :blind_draft_cards, :blind_draft_id, :integer
  end
end
