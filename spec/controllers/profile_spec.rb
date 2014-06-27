require 'spec_helper'

describe ProfilesController do

  describe 'Set Locale' do
    it 'should redirect to root if guest or not logged in' do
      post :set_locale
      response.status.should == 302
    end

    it 'should change to locale if logged in' do
      @user = create(:user)
      sign_in @user
      post :set_locale, { locale: 'zh-CN' }
      @user.reload.profile.locale.should == 'zh-CN'
    end
  end
end
