class AddUndecidedToTournPairs < ActiveRecord::Migration
  def change
    add_column :tourn_pairs, :undecided, :integer
  end
end
