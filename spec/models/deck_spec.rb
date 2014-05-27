require 'spec_helper'

describe Deck do
  let(:deck) { create :deck }
  
  it 'removes all matches if destroyed' do
    create(:match_deck, deck: deck)
    
    expect { deck.destroy }.to change { Match.count }.by(-1)
  end
end