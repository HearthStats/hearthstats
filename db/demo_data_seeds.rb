User.destroy_all
klasses = Klass.all


5.times do |user_count|
  # create user and profile
  user = User.create!(email: "info_#{user_count+1}@example.com", password: 'example')
  Profile.create(user_id: user.id, name: "info_#{user_count+1}")

  # create decks
  (9 + rand(15)).times do |i|
    deck = Deck.new(name:      "demo-deck ##{i}",
                    klass_id:  klasses.sample.id)
    deck.user_id = user.id
    deck.active = [true, false].sample
    deck.is_public = [true, false].sample

    # pick 30 cards
    possible_cards = Card.where("klass_id = ? OR klass_id IS NULL", deck.klass_id)
    deck_cards = {}
    while deck_cards.values.sum < 30 do
      many = deck_cards.length == 29 ? 1 : [1,2].sample
      many.times do
        card = possible_cards.sample
        deck_cards[card] ||= 0
        deck_cards[card] += 1
      end
    end

    # build cardstring
    deck_cards      = deck_cards.sort_by { |card, count| [card.mana, card.name] }
    deck.cardstring = deck_cards.map { |card, count| "#{card.id}_#{count}"}.join(',')

    deck.save!
  end

  # create matches
  rand(100).times do |i|
    result      = [1,2].sample
    result      = 3 if i % 20 == 0
    deck        = user.decks.sample

    match = Match.new(
      result_id:   result,
      mode_id:     [1,2,3].sample,
      klass_id:    deck.klass_id,
      created_at:  rand(100).days.ago
    )
    match.numturns = 4 + rand(15)
    match.oppclass_id = klasses.sample.id
    match.user_id = user.id
    match.coin = [true, false].sample
    match.save!

    MatchDeck.create(deck_id: deck.id, match_id: match.id)

    if match.mode_id == 1
      arena_run = ArenaRun.create(
        user_id:  user.id,
        complete: [true, false].sample,
        klass_id: deck.klass_id
      )

      MatchRun.create(match_id: match.id, arena_run_id: arena_run.id)
    end
  end
end
