require 'spec_helper'

describe BlindDraftsController do
  let(:user) { create :user }
  let(:blind_draft) { create :blind_draft, player1_id: user.id }

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
  end

  describe "POST reveal_card" do
    it "should redirect back to draft" do
      post :reveal_card, blind_draft_card: blind_draft.blind_draft_cards.first.id
      response.should redirect_to draft_blind_draft_path(blind_draft)
    end
    it "should reduce revealed card count by 1" do
      post :reveal_card, blind_draft_card: blind_draft.blind_draft_cards.first.id
      card_count = blind_draft.blind_draft_cards.where(revealed: false).count
      card_count.should equal (blind_draft.card_cap - 1)
    end
  end

  describe "POST pick_card" do
    it "should redirect back to draft" do
      post :pick_card, 
        draft_card: blind_draft.blind_draft_cards.first.id,
        player_id: user.id
      response.should redirect_to draft_blind_draft_path(blind_draft)
    end

    it "should reduce available card count by 1" do
      post :pick_card, 
        draft_card: blind_draft.blind_draft_cards.first.id,
        player_id: user.id
      card_count = blind_draft.blind_draft_cards.where(user_id: nil).count
      card_count.should equal (blind_draft.card_cap - 1)
    end
  end
end
