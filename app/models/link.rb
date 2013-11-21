class Link
  def initialize(url)
    @url = url
    parse
  end

  def parse
    begin
      page = Nokogiri::HTML(open(@url))
      if page.css('header').text.present?
        @html = "<a href='#{@url}'>Link To Deck</a><p>"
      else
        @html = page.text
      end
    rescue OpenURI::HTTPError
      if decklink == "/export/4"
        @html = "No deck link attatched to this deck yet <p>"
      else
        @url = @url[0..-10]
        @html = "<a href='#{url}'>Link To Deck</a><p>"
      end     
    end
  end

  def valid?
    @html.present?
  end

  def html
    @html
  end
end