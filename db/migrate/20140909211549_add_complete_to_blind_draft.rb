class AddCompleteToBlindDraft < ActiveRecord::Migration
  def change
    add_column :blind_drafts, :complete, :boolean, default: false
  end
end
