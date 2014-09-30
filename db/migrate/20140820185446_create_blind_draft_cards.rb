class CreateBlindDraftCards < ActiveRecord::Migration
  def up
    create_table :blind_draft_cards do |t|
      t.integer :user_id
      t.integer :card_id
      t.integer :blind_draft_id
      t.boolean :revealed, default: false
      t.timestamps
    end

  end

  def down
  end
end
