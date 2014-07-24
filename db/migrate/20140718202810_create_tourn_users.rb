class CreateTournUsers < ActiveRecord::Migration
  def change
    create_table :tourn_users do |t|
      t.belongs_to :tournament
      t.integer :user_id
    end
  end
end
