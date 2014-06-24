require 'spec_helper'

describe 'home page' do
  it 'welcomes the user' do
    visit '/'
    page.should have_content('Welcome to HearthStats')
  end

  it 'should go to login page' do
    visit '/'
    click_on 'Sign In'
    page.should have_content('Login to your account')
  end

  it 'should allow user to sign up' do
    visit '/'
    page.find('.signup').click
    page.should have_content('Enter your account details below:')
  end

end