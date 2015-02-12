require 'spec_helper'

describe 'arena_runs' do  
  context 'log in' do 
    it'should log in' do
      sign_in_int
      visit '/arenas'
      click_on 'New Areana Run'
      page.status_code.should be 200
    end
  end

  context 'create new Arena' do
    it 'should load create new Arena page' do
      page.should have_content 'New Arena Match'
    end
  end

  context 'choose classes' do
    it 'should choose Hunter as Classes' do
      select 'Hunter', :from => "Your Class"
      click_on 'Continue'
      page.status_code.should be 200
    end

    it 'should choose Warlock as Classes' do
      select 'Warlock', :from => "Your Class"
      click_on 'Continue'
      page.status_code.should be 200
    end

  end

  context 'choose result' do
    click_on 'Continue'

    it 'should have played first' do
      page.body.should have_content 'Played First'
    end

    it 'should choose play second' do         
      click_on 'Played First'
      page.body.should have_content 'Played Second'
    end

    it 'should choose opponents Class' do
      select 'Mage',:from => "Opponent's Class"
      page.body.should have_content 'Mage'
    end

    it 'should create new win Arena Run' do
      click_on 'Win'
      click_on 'Create entry'
      page.body.should have_content 'Victory'
    end

    it 'should create new defeated Arena Run' do
      click_on 'Defeat'
      click_on 'Create entry'
      #search how to check text in red
      #page.body.should have_content 
    end

    it 'should create new defeated Arena Run' do
      click_on 'Defeat'
      click_on 'Create entry'
      #search how to check text in yellow
      #page.body.should have_content 
    end

    it 'should leave notes' do
      click_on 'Win'
      click_on 'Create entry'
      fill_in 'Notes', :with => 'New areana created'
    end
  end

end