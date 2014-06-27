require 'spec_helper'

describe 'Profile' do

  describe 'Set Locale' do
    it 'should redirect to root if guest or not logged in' do
      post set_locale_profiles_path
      response.status.should == 302
    end

    it 'should change to locale if logged in' do
      sign_in
      post set_locale_profiles_path, { locale: 'zh-CN' }
      @user.profile.locale.should == 'zh-CN'
    end
  end
end
