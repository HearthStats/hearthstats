require "open-uri"

module CardsHelper
  def download_new_card_set(set_id)
    cards = Card.where(card_set_id: set_id)
    cards.each do |c|
      File.write('/Users/Yibo/hearthstats/app/assets/images/cards/' + c.name.parameterize  + '.png',
        open('http://wow.zamimg.com/images/hearthstone/cards/enus/original/' + c.blizz_id + '.png').read, {mode: 'wb'})
    end
  end

end
