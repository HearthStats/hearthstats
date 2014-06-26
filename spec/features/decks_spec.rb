require 'spec_helper'

describe 'decks' do
  context 'public' do
    it 'does not throw an error when the sort column is created_at' do
      visit '/decks/public?sort=created_at'
      
      page.status_code.should == 200
    end
    
    it 'does not throw an error when the sort column is name' do
      visit '/decks/public?sort=name'
      
      page.status_code.should == 200
    end
  end
end
