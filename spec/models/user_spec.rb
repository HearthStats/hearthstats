require 'spec_helper'

describe User do
  let(:user) { build :user }
  
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
end
