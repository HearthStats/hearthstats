require 'spec_helper'
describe 'arena_runs' do  
  before do
    sign_in_int
    visit '/arenas'
    page.find("#new_arena_run").click
  end

  #step 1 click on new arena run
  context 'create new Arena' do
    it 'should load create new Arena page' do
      page.should have_content 'New Arena Run'
    end
  end
  
  #step 2 choose your classes
  context 'choose classes' do
    it 'should choose Hunter as Classes' do
      select 'Hunter', :from => "arena_run[klass_id]"
      click_on 'Continue'
      page.status_code.should be 200
    end

    it 'should choose Warlock as Classes' do
      select 'Warlock', :from => "arena_run[klass_id]"
      click_on 'Continue'
      page.status_code.should be 200
    end
  end

  #step 3 choose results
  context 'choose result' do
    before do
      click_on 'Continue'
    end
    
    #3.1 choose play order
    it 'should have played first' do
      page.should_not have_button("Played First",visible:true)
    end

    #3.2 choose opponent classes
    it 'should choose opponents Class' do
      select 'Mage',:from => "match[oppclass_id]"
      page.status_code.should be 200
    end

    #3.3 create entry
    it 'should create new win Arena Run' do
      page.find("#1").click
      click_on 'Create entry'
      page.should have_selector('table tr', :count => 2)
    end

    #it 'should create new defeated Arena Run' do
     # click_on 'Defeat'
      #click_on 'Create entry'
      #page.body.should have_content 
    #end

    #it 'should create new defeated Arena Run' do
     # click_on 'Defeat'
    #  click_on 'Create entry'
      #search how to check text in yellow
      #page.body.should have_content 
   # end
  end
  
  #step 4 retire and the end
  context 'after retire', js:true do
    before do
      select 'Warlock', :from => "arena_run[klass_id]"
      click_on 'Continue'
      select 'Mage',:from => "match[oppclass_id]"
      page.find("#1").click
      click_on 'Create entry'
      fill_in 'match[notes]', :with => 'New arena created'
      click_on 'Retire'
      alert = page.driver.browser.switch_to.alert 
      alert.accept 
      fill_in "#arena_run_gold", :with => '40'
      fill_in "#arena_run_dust", :with => '50'
      click_on 'finish'
    end

    it'should create new entry' do
      page.should have_selector('table tr', :count => 2)
    end

    it 'should have Warlock as opponents Class'do
      click_on 'Show'
      page.should have_content 'Warlock'
    end

    it 'should have Mage as your class'do
      click_on 'Show'
      page.should have_content 'Mage'
    end

    it 'should have 1 wins with 0 loss and 0 draw'do
      page.should have_content '1/0-0'
    end

    it 'should leave notes' do
      click_on 'Show'
      page.body.should have_content 'New arena created'
    end

  end  
end