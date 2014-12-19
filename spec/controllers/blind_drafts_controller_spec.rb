# require 'spec_helper'

# describe BlindDraftsController do
#   let(:user) { create :user }
#   let(:blind_draft) { create :blind_draft, player2_id: user.id }

#   before do
#     user.add_role :admin
#     sign_in user
#   end

#   describe "GET new" do
#     it "should be successful" do
#       get :new
#       response.should be_success
#     end
#   end

#   describe "GET draft" do
#     it "should be successful" do
#       get :draft, id: blind_draft.id
#       response.should be_success
#     end
#   end

#   describe "PUT reveal_card" do
#     it "should redirect back to draft" do
#       post :reveal_card, blind_draft_card: blind_draft.blind_draft_cards.first.id, 
#         id: blind_draft.id
#       response.should redirect_to draft_blind_draft_path(blind_draft)
#     end
#     it "should reduce revealed card count by 1" do
#       post :reveal_card, blind_draft_card: blind_draft.blind_draft_cards.first.id, 
#         id: blind_draft.id
#       card_count = blind_draft.blind_draft_cards.where(revealed: false).count
#       card_count.should equal (blind_draft.card_cap - 1)
#     end
#   end

#   describe "PUT pick_card" do
#     it "should redirect back to draft" do
#       post :pick_card, 
#         draft_card: blind_draft.blind_draft_cards.first.id,
#         id: blind_draft.id
#       response.should redirect_to draft_blind_draft_path(blind_draft)
#     end

#     it "should reduce available card count by 1" do
#       post :pick_card, 
#         draft_card:  blind_draft.blind_draft_cards.first.id,
#         id:          blind_draft.id
#       card_count = blind_draft.blind_draft_cards.where(user_id: nil).count
#       card_count.should equal (blind_draft.card_cap - 1)
#     end
#   end

#   describe "PUT new_card" do
#     it "should change the card_id" do
#       old_card_id = blind_draft.blind_draft_cards.first.card_id
#       put :new_card,
#         blind_draft_card: blind_draft.blind_draft_cards.first.id,
#         id: blind_draft.id
#       new_card_id = blind_draft.blind_draft_cards.first.card_id

#       old_card_id.should_not equal new_card_id
#     end
#   end

#   describe "POST end_draft" do
#     # it "should complete draft" do
#     #   post :end_draft, id: blind_draft.id
#     #   blind_draft.complete.should equal true
#     # end

#     it 'should redirect to the show page' do
#       post :end_draft, id: blind_draft.id
#       response.should redirect_to blind_draft_path(blind_draft)
#     end
#   end
# end
