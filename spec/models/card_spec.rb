require 'spec_helper'

describe Card do
  it 'is valid' do
    card = build :card
    card.should be_valid
  end
end
