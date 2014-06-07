require 'factory_girl'

FactoryGirl.define do
  factory :season do
    sequence(:num) { |n| n }
  end
end
