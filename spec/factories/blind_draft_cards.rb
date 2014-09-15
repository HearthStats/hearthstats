require 'factory_girl'

FactoryGirl.define do
  factory :blind_draft_card do
    blind_draft
    card
  end
end
