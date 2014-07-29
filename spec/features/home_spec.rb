require 'spec_helper'

describe 'home page' do
  it 'should load' do
    visit '/'
    page.status_code.should be 200
  end

  it 'should go to champanion page' do
    visit '/'
    click_on 'Download'
    page.should have_content('Official Uploader')
  end

  it 'should link to report' do
    visit '/'
    page.should have_content('Stat Report')
  end

end
