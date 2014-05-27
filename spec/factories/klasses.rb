require 'factory_girl'

FactoryGirl.define do
  factory :klass do
    name { Faker::Name.first_name }
  end
end
