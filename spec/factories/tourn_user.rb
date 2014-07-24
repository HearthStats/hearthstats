require 'factory_girl'

FactoryGirl.define do
  factory :tourn_user do
    association :user
    tournament
  end
end
