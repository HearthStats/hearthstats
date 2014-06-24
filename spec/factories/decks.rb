require 'factory_girl'

FactoryGirl.define do
  factory :deck do
    
    factory :deck_with_unique_deck do
      association :unique_deck
      cardstring { unique_deck.cardstring }
    end
  end
end
