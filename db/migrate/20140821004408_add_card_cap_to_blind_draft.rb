class AddCardCapToBlindDraft < ActiveRecord::Migration
  def change
    add_column :blind_drafts, :card_cap, :integer
    add_column :blind_draft_cards, :revealed, :boolean
  end
end
