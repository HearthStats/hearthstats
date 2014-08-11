require 'spec_helper'

describe DecksController do
  let(:deck) { create :deck }
  let(:user) { create :user }

  before do
    sign_in user
  end

  describe 'GET #edit' do
    it 'redirects to root when the deck does not belong to current user' do
      get :edit, id: deck.id

      response.status.should == 302
    end

    it 'loads even when the cardstring is empty' do
      deck.update_attribute(:user_id, user.id)

      get :edit, id: deck.id

      response.status.should == 200
    end
  end

end
