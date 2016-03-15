require 'mechanize'

class DeckScraper
  attr_accessor :decks, :page
  def initialize
    mechanize = Mechanize.new
    @page = mechanize.get('http://www.hearthstonetopdecks.com/deck-category/style/tournament/')
    @page2 = mechanize.get('http://www.hearthstonetopdecks.com/deck-category/style/ladder/')
    @decks = @page.links.select{|link| link.href.include? "/decks/"} + @page2.links.select{|link| link.href.include? "/decks/"}

    @htd_page = mechanize.get('http://www.hearthstonetopdeck.com/')
    @htd_decks = @htd_page.links.select{|link| !link.href.nil? && (link.href.include? "/deck/")}
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
          author = dp.search(".player-wrap h2 a").text
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

    output_decks = []
    @htd_decks.each do |deck_page|
      dp = deck_page.click
      x = dp.search(".cardname span")

      @cardlist = Array.new
      x.each do |card|
        @cardlist << card.text
      end
      unless @cardlist.length == 0
        klass = dp.search(".midlarge span")[1].text
        text = dp.search(".panel-title").first.text
        name = text[(text.index("-") + 2)..(text.rindex("-") - 1)]
        author = dp.search('.panel-title a').first.text.strip
        cardlist = @cardlist.join("\r\n")
        deck_obj = {}
        deck_obj[:name] = name
        deck_obj[:user] = author
        deck_obj[:klass] = klass
        deck_obj[:cards] = cardlist
        output_decks << deck_obj
      end
    end

    return output_decks
  end
end
