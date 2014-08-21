require 'spec_helper'

describe BlindDraft do
  let (:user) { build :user }
  let (:blind_draft) { build :blind_draft}

  describe '#find_player_cards' do
    let (:player1) { build :user }
    let (:player2) { build :user }
    
    it 'should get all cards belonging to player' do
      draft_card1 = create :blind_draft_card, 
        user_id: player1.id, 
        card_id: (1..500).to_a.sample,
        blind_draft_id: blind_draft.id
      draft_card2 = create :blind_draft_card, 
        user_id: player1.id, 
        card_id: (1..500).to_a.sample,
        blind_draft_id: blind_draft.id
      draft_card3 = create :blind_draft_card, 
        user_id: player1.id, 
        card_id: (1..500).to_a.sample,
        blind_draft_id: blind_draft.id

      blind_draft.find_player_cards(player1.id).should == [draft_card1,
                                                           draft_card2,
                                                           draft_card3]
    end
  end
end
