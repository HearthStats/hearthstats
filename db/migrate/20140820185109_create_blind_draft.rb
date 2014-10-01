class CreateBlindDraft < ActiveRecord::Migration
  def up
    create_table :blind_drafts do |t|
      t.string :cardstring
      t.integer :player1_id
      t.integer :player2_id
      t.integer :card_cap
      t.string :klass_string
      t.timestamps
    end
  end

  def down
  end
end
