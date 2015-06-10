class ChangeBlindDraftCardString < ActiveRecord::Migration
  def change
    change_column :blind_drafts, :cardstring, :text, :limit => 4294967295
  end
end
