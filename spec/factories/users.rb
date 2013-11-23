require 'factory_girl'

FactoryGirl.define do
  factory :user do
      email 'bobbyjoe@mailinator'
      password 'secret'
  end
end
