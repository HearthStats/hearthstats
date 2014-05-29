require 'factory_girl'

FactoryGirl.define do
  factory :card do
    name { Faker::Name.name }
  end
end
