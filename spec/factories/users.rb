require 'factory_girl'

FactoryGirl.define do
  factory :user do
    email    { Faker::Internet.email       }
    password { Faker::Internet.password(6) }

    association :profile

    factory :admin do
        after(:create) {|user| user.add_role(:admin)}
    end

    factory :early_sub do
        after(:create) {|user| user.add_role(:early_sub)}
    end
  end
end
