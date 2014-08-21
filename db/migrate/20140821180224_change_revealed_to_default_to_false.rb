class ChangeRevealedToDefaultToFalse < ActiveRecord::Migration
  def change
    change_column :blind_draft_cards, :revealed, :boolean, default: false
  end
end
