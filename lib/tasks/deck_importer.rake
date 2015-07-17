namespace :deck_importer do
  task :hearthstonetopdecks => :environment do
    scraper = DeckScraper.new
    decks = scraper.get_decks
    Text2Deck = Struct.new(:cardstring, :errors)
    def text_to_deck(text)
      text_array = text.split("\r\n")
      card_array = Array.new
      err = Array.new
      text_array.each do |line|
        begin
          qty = /^([1-2])/.match(line)[1]
          name = /^[1-2] (.*)/.match(line)[1]
          card_id = Card.where("lower(name) =?", name.downcase).first.id
        rescue
          err << ("Problem with line '" + line + "'")
          next
        end
        card_array << card_id.to_s + "_" + qty.to_s

      end

      Text2Deck.new(card_array.join(','), err.join('<br>'))
    end
    decks.each do |d|
      if Deck.where(name: d[:name]).count == 0
        new_deck = Deck.new
        text2deck = text_to_deck(d[:cards])
        new_deck.name = d[:name]
        new_deck.cardstring = text2deck.cardstring
        new_deck.klass_id = Klass::LIST.invert[d[:klass]]
        new_deck.created_at = Time.now
        new_deck.updated_at = new_deck.created_at
        new_deck.is_public = true
        new_deck.deck_type_id = 4

        profile = Profile.where(name: d[:user]).first
        if !profile.nil?
          new_deck.user_id = profile.user_id
        else
          user = User.create(
            email: d[:user] + User.count.to_s + 'fakerino@fakerino.com',
            password: 'hellooooo')
          user.get_userkey
          user.save
          user.profile.name = d[:user]
          user.profile.save
          new_deck.user_id = user.id
        end

        new_deck.save
        if new_deck.unique_deck
          new_deck.unique_deck.update_stats!
        end
      end
    end
  end
end
