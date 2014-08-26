require 'spec_helper'

describe User do
  let(:user) { build :user }

  describe 'class methods' do

  end

  describe 'instance methods' do
    describe '#name' do
      it 'should return profile name' do
        user.name.should == user.profile.name
      end
    end

    describe '#blind_drafts' do
      it 'should return all user blind_drafts' do
        player = create :user
        blind_draft1 = create :blind_draft, player1_id: player.id
        blind_draft2 = create :blind_draft, player2_id: player.id
        player.blind_drafts.should == [ blind_draft1, blind_draft2]
      end
    end
    describe '#get_user_key' do
      it 'sets the userkey when it is not present' do
        user.get_userkey

        user.userkey.should_not be_empty
      end

      it 'returns the userkey' do
        user.userkey = '666'

        user.get_userkey.should == '666'
      end
    end

    describe '#is_new?' do
      it 'returns true if the user has no constructed or arena' do
        user.is_new?.should be_true
      end

      it 'returns false if the user has played a match' do
        create(:match, user: user)

        user.is_new?.should be_false
      end
    end
  end
end
