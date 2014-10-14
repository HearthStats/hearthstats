namespace :tournerino do
  task :create_group_tournament_with_decks => :environment do
    tournament = Tournament.create(name: "testerino", best_of: 3, num_pods: 4, bracket_format: 0, num_decks: 3, num_players: 16)
    16.times do
      user = User.create(email: Faker::Internet.email, password: Faker::Internet.password(6))
      t_user = TournUser.create(tournament_id: tournament.id, user_id: user.id)
      3.times do
        deck = Deck.create(name: Faker::Name.name, user_id: user.id)
        TournDeck.create(tournament_id: tournament.id, deck_id: deck.id, tourn_user_id: t_user.id)
      end
    end
    puts "Created tournament with 16 users with decks."
  end
end
