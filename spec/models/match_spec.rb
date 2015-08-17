require 'spec_helper'

describe Match do
  describe "class methods" do
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

      let(:deck_klass_id) { 3 }
      let(:user_id) { 1 }
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

  describe "instance methods" do
  end
end
