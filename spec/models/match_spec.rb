require 'spec_helper'

describe Match do
  describe "class methods" do
  describe 'custom validations' do
    it 'should not allow creation of duplicate matches' do
      match_params = {klass_id: 1, result_id: 2, mode_id: 3, user_id: 4 }
      match = Match.create(match_params)
      expect(match).to be_valid

      duplicate_match = Match.new(match_params)
      expect(duplicate_match).to_not be_valid
    end
  end
    describe '::bestuserarena' do
      let(:user) { build :user }

      it 'returns class and winrate for a users best performing class' do
        create :match, klass_id: 1, result_id: 1, mode_id: 1, user: user
        create :match, klass_id: 2, result_id: 2, mode_id: 1, user: user
        create :match, klass_id: 2, result_id: 1, mode_id: 1, user: user
        create :match, klass_id: 1, result_id: 2, mode_id: 1, user_id: 666

        Match.bestuserarena(user.id).should == ["Druid", 100]
      end
    end

    describe '::winrate_per_class' do
      it 'inits all classes to 0' do
        Match.winrate_per_class(Match).should == [0, 0, 0, 0, 0, 0, 0, 0, 0]
      end

      it 'calculates the winrate per class' do
        klass = create :klass
        win   = create :match, klass: klass, result_id: 1
        loss  = create :match, klass: klass, result_id: 0

        Match.winrate_per_class(Match).should == [50, 0, 0, 0, 0, 0, 0, 0, 0]
      end
    end

    describe '::matches_per_class' do
      it 'inits all classes to 0' do
        Match.matches_per_class.should == { "Druid"=>0, "Hunter"=>0, "Mage"=>0, "Paladin"=>0, "Priest"=>0, "Rogue"=>0, "Shaman"=>0, "Warlock"=>0, "Warrior"=>0 }
      end

      it 'returns the number of played matches per class' do
        create :match, klass_id: 1
        create :match, klass_id: 3

        Match.matches_per_class.should == { "Druid"=>1, "Hunter"=>0, "Mage"=>1, "Paladin"=>0, "Priest"=>0, "Rogue"=>0, "Shaman"=>0, "Warlock"=>0, "Warrior"=>0 }
      end
    end

    describe '::top_winrates_with_class' do
      it 'inits all classes to 0' do
        Match.top_winrates_with_class.should == [0, 0, 0, 0, 0, 0, 0, 0, 0]
      end

      it 'calculates the winrate per class' do
        klass = create :klass
        win   = create :match, klass: klass, result_id: 1
        loss  = create :match, klass: klass, result_id: 0

        Match.top_winrates_with_class.should == [["Druid", 50.0], 0, 0, 0, 0, 0, 0, 0, 0]
      end
    end

    context 'when mass-importing new matches' do

      describe '::mass_import_new_matches' do
        let(:ranked_match) { double(:ranked_match) }
        let(:arena_match) { double(:arena_match) }
        let(:matches_params) { [ranked_match, arena_match] }
        let(:deck_id) { 13 }
        let(:deck_klass_id) { 7 }
        let(:user_id) { 5 }
        let(:last_match) { double(:last_match) }

        before(:each) do
          Match.stub(:generate_mass_insert_sql)
          Match.connection.stub(:insert).and_return(0)
          Match.stub(:last).and_return(last_match)
          last_match.stub(:id).and_return(1)
          [ranked_match, arena_match].each { |m| m.stub(:[]=); m.stub(:[]) }
          MatchDeck.stub(:generate_mass_insert_sql)
        end

        it 'generates and executes a match mass-insert sql command' do
          Match.should_receive(:generate_mass_insert_sql)
            .with(matches_params, 7, 5)
            .and_return("INSERT luck INTO forsen")
          Match.connection.should_receive(:insert).with("INSERT luck INTO forsen")

          Match.mass_import_new_matches(matches_params, deck_id, deck_klass_id, user_id)
        end

        it "adds the matches' ids to their param values" do
          Match.connection.stub(:insert).and_return(4)
          last_match.stub(:id).and_return(5)

          ranked_match.should_receive(:[]=).with(:id, 4)
          arena_match.should_receive(:[]=).with(:id, 5)

          Match.mass_import_new_matches(matches_params, deck_id, deck_klass_id, user_id)
        end

        it 'generates and executes a MatchDeck mass-insert sql command' do
          MatchDeck.should_receive(:generate_mass_insert_sql)
            .with(matches_params, 13)
            .and_return("INSERT drboom INTO turn7")
          MatchDeck.connection.should_receive(:insert).with("INSERT drboom INTO turn7")
          Match.mass_import_new_matches(matches_params, deck_id, deck_klass_id, user_id)
        end

        it 'generates and executes a MatchRank mass-insert sql command' do
          ranked_match.should_receive(:[]).with(:mode).and_return("Ranked")
          ranked_match.should_receive(:[]).with(:ranklvl).and_return("1")

          MatchRank.should_receive(:generate_mass_insert_sql)
            .with([ranked_match])
            .and_return("INSERT value INTO valuetown")
          MatchRank.connection.should_receive(:insert).with("INSERT value INTO valuetown")
          Match.mass_import_new_matches(matches_params, deck_id, deck_klass_id, user_id)
        end
      end

      describe '::generate_mass_insert_sql' do
        let(:matches_params) do
          [{
            mode: "Ranked",
            oppclass: "Priest",
            result: "Win",
            coin: "false"
          }, {
            mode: "Arena",
            oppclass: "Warlock",
            result: "Loss",
            coin: "true"
          }]
        end

        let(:user_id) { 1 }
        let(:deck_klass_id) { 3 }
        let!(:time_now) { Time.now }
        let(:db_time) { time_now.to_s(:db) }

        before(:each) do
          Time.stub(:now).and_return(time_now)
        end

        it 'generates a mass insert sql string' do
          insert_sql = Match.generate_mass_insert_sql(matches_params, deck_klass_id, user_id)
          expect(insert_sql).to eq(<<-SQL)
INSERT INTO matches (`user_id`, `mode_id`, `klass_id`, `result_id`, `coin`, `oppclass_id`, `oppname`, `numturns`, `duration`, `notes`, `appsubmit`, `created_at`, `updated_at`)
VALUES (1,3,3,1,0,5,NULL,NULL,NULL,NULL,1,'#{db_time}','#{db_time}'),(1,1,3,2,1,8,NULL,NULL,NULL,NULL,1,'#{db_time}','#{db_time}')
          SQL
        end

        context 'when fending off sneaky pranksters' do
          let(:matches_params) do
            [{
              mode: "Ranked",
              oppclass: "Priest",
              result: "Win",
              coin: "false",
              notes: "ripperino trumpW',NULL,NULL);DROP TABLE users"
            }]
          end

          it 'properly sanitizes sql inputs' do
            insert_sql = Match.generate_mass_insert_sql(matches_params, deck_klass_id, user_id)
            expect(insert_sql).to eq(<<-SQL)
INSERT INTO matches (`user_id`, `mode_id`, `klass_id`, `result_id`, `coin`, `oppclass_id`, `oppname`, `numturns`, `duration`, `notes`, `appsubmit`, `created_at`, `updated_at`)
VALUES (1,3,3,1,0,5,NULL,NULL,NULL,'ripperino trumpW\\',NULL,NULL);DROP TABLE users',1,'#{db_time}','#{db_time}')
            SQL
          end
        end
      end
    end
  end
end
