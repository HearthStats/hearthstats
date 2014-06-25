require 'spec_helper'

describe 'static pages' do
  it 'should load about us' do
    visit '/aboutus'
    page.should have_content('About Us')
  end

  it 'should load contact us' do
    visit '/contactus'
    page.should have_content('Contact Info')
  end

  it 'should load help' do
    visit '/help'
    page.should have_content('Help')
  end

  it 'should load openings' do
    visit '/openings'
    page.should have_content('Openings')
  end

  it 'should load privacy policy' do
    visit '/privacy'
    page.should have_content('Privacy Policy')
  end



end
