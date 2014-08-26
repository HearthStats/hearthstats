require 'factory_girl'

FactoryGirl.define do
  factory :tournament do
    bracket_format  { [1,2,3].sample     }
  end
end
