require 'factory_girl'

FactoryGirl.define do
  factory :unique_deck_card do
    unique_deck
    card
  end
end
