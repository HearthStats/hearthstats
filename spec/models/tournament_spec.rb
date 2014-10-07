require 'spec_helper'
require 'awesome_print'

describe Tournament do

  describe "single elim brackets" do
    let(:tournament) { build :tournament, bracket_format: 1, name: "test", num_decks: 3 }
    describe "#initiate_brackets" do
      # tests pick unique situations in bracket positioning, and
      # checks for:
      # =>  correct number of pairings
      # =>  correct positioning of bracket excluding residual
      # =>  correct positioning of residual pairings
      # =>  no duplicate users (errors in bracket generation)
      it "creates pairings for 8 users" do
        # perfect number of users, no residual
        8.times do
          create :tourn_user, tournament_id: tournament.id
        end
        tournament.start_tournament
        pairs = TournPair.where(tournament_id: tournament.id)
        pairs.count.should == 7
        confirm_top8_pairs(pairs)
        check_for_duplicate_users(pairs)
      end

      it "creates pairings for 10 users and residual pairs should have position 1 and 5" do
        # residual users but only the right children
        10.times do
          create :tourn_user, tournament_id: tournament.id
        end
        tournament.start_tournament
        pairs = TournPair.where(tournament_id: tournament.id)
        pairs.count.should == 9
        r16_pairs = pairs.select { |p| p.roundof == 16 }
        r16_pairs.count.should == 2
        r16_pairs.first.pos.should == 1
        r16_pairs.last.pos.should == 5
        confirm_top8_pairs(pairs)
        check_for_duplicate_users(pairs)
      end

      it "creates pairings for 13 users and residual pairs should have position 1,2,3,5,7" do
        # enough residual users to wrap around and populate left children
        13.times do
          create :tourn_user, tournament_id: tournament.id
        end
        tournament.start_tournament
        pairs = TournPair.where(tournament_id: tournament.id)
        pairs.count.should == 12
        r16_pairs = pairs.select { |p| p.roundof == 16 }
        r16_pairs.count.should == 5
        r16_pairs.any?{ |p| p.pos == 0 }.should == true
        r16_pairs.any?{ |p| p.pos == 1 }.should == true
        r16_pairs.any?{ |p| p.pos == 3 }.should == true
        r16_pairs.any?{ |p| p.pos == 5 }.should == true
        r16_pairs.any?{ |p| p.pos == 7 }.should == true
        confirm_top8_pairs(pairs)
        check_for_duplicate_users(pairs)
      end
    end
  end # single elim

  describe "group stage" do
    let(:tournament) { build :tournament, bracket_format: 0, name: "test", num_decks: 3, num_pods: 4}
    describe "#initiate_groups" do
      it "creates pairings for round robin for 16 users in 4 pods" do
        # perfect number of users, no residual
        16.times do
          create :tourn_user, tournament_id: tournament.id
        end
        tournament.start_tournament
        pairs = TournPair.where(tournament_id: tournament.id)
        pairs.count.should == 24
        tournament.get_num_pairings_in_pod(1).should == 6
        tournament.get_num_pairings_in_pod(2).should == 6
        tournament.get_num_pairings_in_pod(3).should == 6
        tournament.get_num_pairings_in_pod(4).should == 6
      end

      it "creates pairings for round robin for 19 users in 4 pods, where residual users are spread evenly into pods" do
        # residual users spread evenly
        19.times do
          create :tourn_user, tournament_id: tournament.id
        end
        tournament.start_tournament
        pairs = TournPair.where(tournament_id: tournament.id)
        pairs.count.should == 36
        tournament.get_num_pairings_in_pod(1).should == 10
        tournament.get_num_pairings_in_pod(2).should == 10
        tournament.get_num_pairings_in_pod(3).should == 10
        tournament.get_num_pairings_in_pod(4).should == 6
      end
    end
  end # group stage

  def confirm_top8_pairs(pairs)
    r8_pairs = pairs.select { |p| p.roundof == 8 }
    r8_pairs.count.should == 4
    r4_pairs = pairs.select { |p| p.roundof == 4 }
    r4_pairs.count.should == 2
    r1_pairs = pairs.select { |p| p.roundof == 2 }
    r1_pairs.count.should == 1
  end

  def check_for_duplicate_users(pairs)
    user_list = []
    pairs.each do |pair|
      case pair.undecided
      when -1
        user_list.push(pair.p1_id)
        user_list.push(pair.p2_id)
      when 1
        user_list.push(pair.p1_id)
      end
    end
    user_list.uniq.length.should == user_list.length
  end
end