FactoryGirl.define do
  factory :unique_deck_type do
    sequence(:match_string, 1) { |n| "#{n * 2}_2,#{(n * 2) + 1}_2" }
    klass_id 1
  end
end
