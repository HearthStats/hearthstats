require 'spec_helper'

describe Match do
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
end
