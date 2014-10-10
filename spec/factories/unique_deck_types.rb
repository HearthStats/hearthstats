require 'factory_girl'

FactoryGirl.define do
  factory :unique_deck_type do
    match_string "2,4"
  end
end
