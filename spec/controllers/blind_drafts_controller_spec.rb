require 'spec_helper'

describe BlindDraftsController do
  let(:user) { create :user }
  let(:blind_draft) { create :blind_draft }

  before do
    sign_in user
  end

  describe "GET new" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "GET draft" do
    it "should be successful" do
      get :draft, id: blind_draft.id
      response.should be_success
    end
    it "should have total cards in draft" do
      get :draft, id: blind_draft.id
      card_count = blind_draft.blind_draft_cards.count
      response.should have_selector('#cards-left', text: card_count)
    end
  end

  describe "POST reveal_card" do
    it "should redirect back to draft" do
      post :reveal_card
      response.should redirect_to draft_blind_draft_path(blind_draft)
    end
    it "should reduce card count by 1" do
      post :reveal_card, id: blind_draft.blind_draft_cards.first.id
      card_count = blind_draft.blind_draft_cards.count
      card_count.should equal (blind_draft.card_cap - 1)
    end
  end
end
