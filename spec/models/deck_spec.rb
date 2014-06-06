require 'spec_helper'

describe Deck do
  let(:deck) { build :deck }
  
  it 'removes all matches if destroyed' do
    deck.save
    create(:match_deck, deck: deck)
    
    expect { deck.destroy }.to change { Match.count }.by(-1)
  end
  
  it 'strips blanks from the name' do
    deck.name = ' rubbish '
    deck.save
    
    deck.name.should == 'rubbish'
  end
  
  it 'sets the name to unnamed if left blank' do
    deck.name = ''
    deck.save
    
    deck.name.should == '[unnamed]'
  end
  
  it 'creates an unique_deck if there are 30 cards and the deck is unique' do
    deck.stub(:num_cards).and_return 30
    deck.cardstring = "2_2"
    deck.klass_id   = 1
    
    expect { deck.save }.to change { UniqueDeck.count }.by(1)
  end
  
  it 'sets unique_deck_id' do
    deck.stub(:num_cards).and_return 30
    deck.cardstring = "2_2"
    deck.klass_id   = 1
    deck.save
    
    deck.unique_deck_id.should == UniqueDeck.last.id
  end
  
  describe 'instance methods' do
    describe '#card_array_from_cardstring' do
      it 'returns the cards ordered by mana and then name' do
        card1 = create :card, id: 500, mana: 1, name: 'aaa'
        card2 = create :card, id: 600, mana: 1, name: 'bbb'
        card3 = create :card, id: 700, mana: 2, name: 'ccc'
        cardstring = "700_1,600_1,500_2"
        deck = build :deck, cardstring: cardstring
      
        deck.card_array_from_cardstring.should == [[card1,2], [card2,1],[card3,1]]
      end
    
      it 'returns an empty array if the cardstring is nil' do
        deck.card_array_from_cardstring.should == []
      end
    end
    
    describe '#update_user_stats!' do
      let!(:deck) { create :deck                            }
      let!(:win)  { create :match, deck: deck, result_id: 1 }
      let!(:loss) { create :match, deck: deck, result_id: 2 }
      
      before { deck.update_user_stats! }
      
      it 'sets user_num_matches to the decks matches count' do
        deck.user_num_matches.should == 2
      end
      
      it 'sets user_num_wins' do
        deck.user_num_wins.should == 1
      end
      
      it 'sets user_num_losses' do
        deck.user_num_losses.should == 1
      end
      
      it 'sets the winrate' do
        deck.user_winrate.should == 50
      end
      
      it 'saves the results' do
        deck.reload.user_winrate.should == 50
      end
    end
  end
end
