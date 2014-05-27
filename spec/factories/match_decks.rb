require 'factory_girl'

FactoryGirl.define do
  factory :match_deck do
    association :deck
    association :match
  end
end
