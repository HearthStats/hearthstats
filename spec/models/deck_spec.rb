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
  
end