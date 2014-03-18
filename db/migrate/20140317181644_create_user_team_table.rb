class CreateUserTeamTable < ActiveRecord::Migration
  def up
    create_table :team_users do |t|
      t.integer :user_id
      t.integer :team_id
    end
  end

  def down
  end
end
