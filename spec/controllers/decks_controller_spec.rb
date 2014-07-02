require 'spec_helper'

describe DecksController do
  let(:deck) { create :deck }
  
  describe 'GET #edit' do
    it 'redirects to root when the deck does not belong to current user' do
      user = create(:user)
      sign_in user
      
      get :edit, id: deck.id
      
      response.status.should == 302
    end
    
    it 'loads even when the cardstring is empty' do
      user = create(:user)
      deck.update_attribute(:user_id, user.id)
      sign_in user
      
      get :edit, id: deck.id
      
      response.status.should == 200
    end
  end

end
