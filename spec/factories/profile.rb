require 'factory_girl'

FactoryGirl.define do

  factory :profile do
    name { Faker::Name.first_name }
  end
end
