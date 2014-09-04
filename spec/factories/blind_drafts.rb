require 'factory_girl'

FactoryGirl.define do
  factory :blind_draft do
    
    cardstring "241,147,99,6,339,361,87,371,127,42,267,32,15,171,175,204,103,197,38,173,138,203,95,49,180,236,336,191,276,140,187,288,168,181,222,179,125,68,380,164,39,375,22,309,240,306,332,310,382,298,325,45,364,376"

    card_cap 54

    # The cards that are created will match the cardstring
    after(:create) do |blind_draft, evaluator|
      evaluator.cardstring.split(',').each do |id|
        card  = Card.exists?(id) ? Card.find(id) : create(:card, id: id)

        create_list(:blind_draft_card, 1, card: card, blind_draft: blind_draft)
      end
    end
  end
end
