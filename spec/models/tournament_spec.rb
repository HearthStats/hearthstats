require 'spec_helper'

describe Tournament do

  describe "single elim brackets" do
    let(:tournament) { build :tournament, bracket_format: 1 }
    describe "#initiate_brackets" do
      it "creates brackets with power of 2 number of players" do
        4.times do
          create :tourn_user, tournament_id: tournament.id
        end
        tournament.tourn_pairs.count.should == 2
      end
    end
  end #single elim

end
