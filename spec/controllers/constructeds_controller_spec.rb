require 'spec_helper'

describe ConstructedsController do
  let(:user) { create :user }

  before do
    sign_in user
  end

  it 'redirects to constructed/new when deckname is empty' do
    post :create

    response.should redirect_to new_constructed_path
  end

  it 'redirects to constructed/new when deck can not be found' do
    post :create, deckname: 'to_legendary_and_beyond!'

    response.should redirect_to new_constructed_path
  end

  it 'redirects to index if the other param is not present' do
    deck = create :deck, name: 'to_legendary_and_beyond!', user_id: user.id

    post :create, deckname: 'to_legendary_and_beyond!'

    response.should redirect_to constructeds_path
  end

  it 'sets @my_decks when the match can not be saved' do
    deck = create :deck, name: 'to_legendary_and_beyond!', user_id: user.id
    post :create, deckname: 'to_legendary_and_beyond!', other: { rank: "Ranked" }

    assigns(:my_decks).should == []
  end
end
