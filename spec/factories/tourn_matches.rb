require 'factory_girl'

FactoryGirl.define do
  factory :tourn_match do
    user
    deck
    result_id { [0,1,2].sample }
  end
end