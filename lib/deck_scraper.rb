require 'mechanize'

class DeckScraper
  attr_accessor :decks, :page
  def initialize
    mechanize = Mechanize.new
    @page = mechanize.get('http://www.hearthstonetopdecks.com/deck-category/style/tournament/')
    @page2 = mechanize.get('http://www.hearthstonetopdecks.com/deck-category/style/ladder/')
    @decks = @page.links.select {|link| link.href.include? "/decks/"} + @page2.links.select{|link| link.href.include? "/decks/"}
  end

  def get_decks
    output_decks = []
    @decks.each do |deck_page|
      unless deck_page.href.nil?
        dp = deck_page.click
        x = dp.search("div#deck-master li a")
        @cardlist = Array.new
        x.each do |card|
          @cardlist << card.search("span.card-count").text + " " + card.search("span.card-name").text
        end

        unless @cardlist.length == 0
          klass = dp.search(".deck-info a").first.text
          name = dp.search(".entry-header .entry-title").text
          author = dp.search(".deck-player").text
          cardlist = @cardlist.join("\r\n")
          deck_obj = {}
          deck_obj[:name] = name
          deck_obj[:user] = author
          deck_obj[:klass] = klass
          deck_obj[:cards] = cardlist
          output_decks << deck_obj
        end
      end
    end

    return output_decks
  end

  def get_decks_htd
    mechanize = Mechanize.new
    @page = mechanize.get('http://www.hearthstonetopdeck.com/')
    @decks = @page.links

    output_decks = []
    @decks.each do |deck_page|
      unless !deck_page.href.nil? && !(deck_page.href.include? "deck.php")
        dp = deck_page.click
        x = dp.search("div.cardname span")
        @cardlist = Array.new
        x.each do |card|
          @cardlist << card.text
        end
        unless @cardlist.length == 0
          tournament = dp.search("div#leftbar div.headbar div").first.text.strip
          klass = dp.search("td span.midlarge span").first.text
          text = dp.search("div#center div.headbar div").first.content
          name = text[(text.index("-") + 2)..(text.rindex("-") - 1)]
          author = text[(text.rindex("-") + 2)..-1]
          cardlist = @cardlist.join("\r\n")
          deck_obj = {}
          deck_obj[:name] = name + ": " + tournament
          deck_obj[:user] = author
          deck_obj[:klass] = klass
          deck_obj[:cards] = cardlist
          output_decks << deck_obj
        end
      end
    end

    return output_decks
  end
end
