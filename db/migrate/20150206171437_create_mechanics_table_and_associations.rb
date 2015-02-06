class CreateMechanicsTableAndAssociations < ActiveRecord::Migration
  def change
    create_table :mechanics do |t|
      t.string :name
    end
    create_table :card_mechanics do |t|
      t.belongs_to :card, index: true
      t.belongs_to :mechanic, index: true
    end
  end
end
