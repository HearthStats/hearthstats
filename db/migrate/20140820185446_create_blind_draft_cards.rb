class CreateBlindDraftCards < ActiveRecord::Migration
  def up
    create_table :blind_card_draft do |t|
      t.integer :user_id
      t.integer :card_id
    end

  end

  def down
  end
end
