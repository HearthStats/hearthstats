require 'spec_helper'

describe 'decks' do
  context 'public' do
    it 'does not throw an error when the sort column is ambiguous' do
      visit '/decks/public?sort=created_at'
      
      page.status_code.should == 200
    end
  end
end
