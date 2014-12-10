require 'spec_helper'

describe 'home page' do
  before do
    Rails.cache.write('wel#arena_top', [])
    Rails.cache.write('wel#con_top', [])
  end

  after do
    Rails.cache.delete('wel#arena_top')
    Rails.cache.delete('wel#con_top')
  end

  it 'should load' do
    visit '/'
    page.status_code.should be 200
  end

  it 'should go to companion page' do
    visit '/'
    click_on 'Companion'
    page.status_code.should be 200
  end

  it 'should go to login page' do
    visit '/'
    click_on 'Web App'
    page.should have_content('Login')
  end

  it 'should link to report' do
    visit '/'
    page.should have_content('Stat Report')
  end

end
