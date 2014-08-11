require 'spec_helper'

describe 'home page' do
  it 'should load' do
    visit '/'
    page.status_code.should be 200
  end

  it 'should go to companion page' do
    visit '/'
    click_on '.uploader-btn'
    page.should have_content('Official Uploader')
  end

  it 'should go to login page' do
    visit '/'
    click_on '.web-app-btn'
    page.should have_content('Login')
  end

  it 'should link to report' do
    visit '/'
    page.should have_content('Stat Report')
  end

end
