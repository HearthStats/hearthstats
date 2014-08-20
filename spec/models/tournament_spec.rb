require 'spec_helper'

describe Tournament do

  describe "single elim brackets" do
    let(:tournament) { build :tournament, bracket_format: 1 }
    describe "#initiate_brackets" do
      it "creates pairings for 8 users" do
        8.times do
          create :tourn_user, tournament_id: tournament.id
        end
        TournUser.where(tournament_id: tournament.id).count.should == 8
        TournPair.where(tournament_id: tournament.id).count.should == 7
      end

      it "creates pairings for 10 users" do
        10.times do
          create :tourn_user, tournament_id: tournament.id
        end
        TournUser.where(tournament_id: tournament.id).count.should == 10
        TournPair.where(tournament_id: tournament.id).count.should == 9
      end
    end
  end #single elim

end
