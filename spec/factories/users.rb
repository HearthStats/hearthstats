require 'factory_girl'

FactoryGirl.define do
  factory :user do
    email    { Faker::Internet.email       }
    password { Faker::Internet.password(6) }

    association :profile
  end
end
