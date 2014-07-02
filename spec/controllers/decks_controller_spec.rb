require 'spec_helper'

describe DecksController do
  let(:deck) { create :deck }

  describe 'GET #edit' do

    context 'when cardstring is blank' do
      it 'should still load' do
        user = create(:user)
        sign_in user
        get edit_deck_path(deck)

        response.status.should == 200
      end
    end
    
  end

end
