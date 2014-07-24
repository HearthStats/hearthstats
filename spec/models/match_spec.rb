require 'spec_helper'

describe Match do
  describe "class methods" do
    describe '#bestuserarena' do
      let(:user) { build :user }
      
      it 'returns class and winrate for a users best performing class' do
        create :match, klass_id: 1, result_id: 1, mode_id: 1, user: user
        create :match, klass_id: 2, result_id: 2, mode_id: 1, user: user
        create :match, klass_id: 2, result_id: 1, mode_id: 1, user: user
        create :match, klass_id: 1, result_id: 2, mode_id: 1, user_id: 666
        
        Match.bestuserarena(user.id).should == ["Druid", 100]
      end
    end
    
    describe '#winrate_per_class' do
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
    
    describe '#matches_per_class' do
      it 'inits all classes to 0' do
        Match.matches_per_class.should == { "Druid"=>0, "Hunter"=>0, "Mage"=>0, "Paladin"=>0, "Priest"=>0, "Rogue"=>0, "Shaman"=>0, "Warlock"=>0, "Warrior"=>0 }
      end
      
      it 'returns the number of played matches per class' do
        create :match, klass_id: 1
        create :match, klass_id: 3
        
        Match.matches_per_class.should == { "Druid"=>1, "Hunter"=>0, "Mage"=>1, "Paladin"=>0, "Priest"=>0, "Rogue"=>0, "Shaman"=>0, "Warlock"=>0, "Warrior"=>0 }
      end
    end
  end

  describe "instance methods" do
    describe "#get_wr_per_day" do
      it 'inits to 0' do
        Match.all.get_wr_per_day.should == Array.new(20).map{|q| q.to_i}
      end
    end

  end
end
