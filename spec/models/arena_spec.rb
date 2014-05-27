require 'spec_helper'

describe Arena do
  describe '#bestuserarena' do
    let(:user) { build :user }
    
    it 'returns class and winrate for a users best performing class' do
      create :arena, userclass: 'Paladin', win: true,  user: user
      create :arena, userclass: 'Paladin', win: false, user: build(:user)
      create :arena, userclass: 'Mage',    win: false, user: user
      create :arena, userclass: 'Mage',    win: true,  user: user
      create :arena, userclass: 'Warrior', win: false, user: user
      
      Arena.bestuserarena(user.id).should == ['Paladin', 100]
    end
    
    it 'returns the first klass if there is no result' do
      create :klass, name: 'Druid'
      Arena.bestuserarena(user.id).should == ['Druid', 0]
    end
  end
end
