require 'factory_girl'

FactoryGirl.define do
  factory :unique_deck do

    cardstring "2_2,4_2"

    # The cards that are created will match the cardstring
    after(:create) do |unique_deck, evaluator|
      evaluator.cardstring.split(',').each do |card|
        id, count = card.split('_')
        card  = create(:card, id: id)

        create_list(:unique_deck_card, count.to_i, card: card, unique_deck: unique_deck)
      end
    end
  end

end
