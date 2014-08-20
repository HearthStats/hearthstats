require 'factory_girl'

FactoryGirl.define do
  factory :tourn_user do
    association :user
    association :tournament
  end
end
