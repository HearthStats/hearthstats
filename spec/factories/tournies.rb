# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tourny do
    challonge_id 1
    status 1
    winner_id 1
    prize "MyString"
  end
end
