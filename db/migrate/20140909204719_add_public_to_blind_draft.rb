class AddPublicToBlindDraft < ActiveRecord::Migration
  def change
    add_column :blind_drafts, :public, :boolean, default: false
  end
end
