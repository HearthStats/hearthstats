require 'spec_helper'

describe UniqueDeck do
  let(:unique_deck) { build :unique_deck }
  
  describe '#update_cards_from_cardstring' do
    it 'removes existing unique deck cards' do
      create :unique_deck_card, unique_deck: unique_deck
      
      expect { unique_deck.reload.update_cards_from_cardstring }.to change { UniqueDeckCard.count }.by(-1)
    end
  end
  
  describe '#update_stats' do
    it 'has empty stats without cards' do
      %w(num_minions num_spells num_weapons num_users num_matches num_wins num_losses winrate).each do |var|
        unique_deck.send(var).should be_nil
      end
    end
    
    it 'sets num_minions' do
      card = create :card, type_id: 1
      create :unique_deck_card, card: card, unique_deck: unique_deck
      unique_deck.update_stats
      
      unique_deck.num_minions.should == 1
    end
    
    it 'sets num_spells' do
      card = create :card, type_id: 2
      create :unique_deck_card, card: card, unique_deck: unique_deck
      unique_deck.update_stats
      
      unique_deck.num_spells.should == 1
    end
    
    it 'sets num_weapons' do
      card = create :card, type_id: 3
      create :unique_deck_card, card: card, unique_deck: unique_deck
      unique_deck.update_stats
      
      unique_deck.num_weapons.should == 1
    end
    
    it 'sets num_users' do
      create :deck, unique_deck: unique_deck, klass_id: unique_deck.klass_id
      unique_deck.update_stats
      
      unique_deck.num_users.should == 1
    end
    
    it 'sums user_num_matches from decks' do
      create :deck, unique_deck: unique_deck, user_num_matches:10
      create :deck, unique_deck: unique_deck, user_num_matches:6
      unique_deck.reload.update_stats
      
      unique_deck.num_matches.should == 16
    end
    
    it 'sums user_num_wins' do
      create :deck, unique_deck: unique_deck, user_num_wins: 1
      create :deck, unique_deck: unique_deck, user_num_wins: 2
      unique_deck.reload.update_stats
      
      unique_deck.num_wins.should == 3
    end
    
    it 'sums user_num_losses' do
      create :deck, unique_deck: unique_deck, user_num_losses: 3
      create :deck, unique_deck: unique_deck, user_num_losses: 2
      unique_deck.reload.update_stats
      
      unique_deck.num_losses.should == 5
    end
    
    it 'calculates winrate' do
      create :deck, unique_deck: unique_deck, user_num_matches: 10, user_num_wins: 1
      create :deck, unique_deck: unique_deck, user_num_matches: 6,  user_num_wins: 2
      unique_deck.reload.update_stats
      
      unique_deck.winrate.should == 18.75
    end
  end
end
