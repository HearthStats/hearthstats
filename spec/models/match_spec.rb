require 'spec_helper'

describe Match do
  describe "class methods" do
    describe '#bestuserarena' do
      let(:user) { build :user }
      
      it 'returns class and winrate for a users best performing class' do
        klass_1 = create :klass
        klass_2 = create :klass
        create :match, klass: klass_1, result_id: 1, mode_id: 1, user: user
        create :match, klass: klass_2, result_id: 2, mode_id: 1, user: user
        create :match, klass: klass_2, result_id: 1, mode_id: 1, user: user
        create :match, klass: klass_1, result_id: 2, mode_id: 1, user: build(:user)
        
        Match.bestuserarena(user.id).should == [klass_1.name, 100]
      end
    end
    
    describe '#winrate_per_class' do
      it 'inits all classes to 0' do
        Match.winrate_per_class.should == {1=>0, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0}
      end
      
      it 'calculates the winrate per class' do
        klass = create :klass
        win   = create :match, klass: klass, result_id: 1
        loss  = create :match, klass: klass, result_id: 0
        
        Match.winrate_per_class.should == {1=>50, 2=>0, 3=>0, 4=>0, 5=>0, 6=>0, 7=>0, 8=>0, 9=>0}
      end
    end
  end
end
