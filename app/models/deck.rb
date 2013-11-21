class Deck < ActiveRecord::Base
  attr_accessible :loses, :name, :wins, :race, :decklink
  has_many :constructeds

  after_destroy :delete_all_constructed

  is_impressionable
  
  extend FriendlyId
  friendly_id :name, use: :slugged

  def delete_all_constructed
  	Constructed.destroy_all(:deck_id => self.id)	
  end

  def decklink_message 
    
    # Add http:// to link if not present
    # If page is not a valid link then return link
    # Else return list of cards in deck
    # If Nokogiri fails to parse, return No deck link if blank
    # Else return link
    begin
      link = prepend_http(decklink)
      page = Nokogiri::HTML(open(link))
      if page.css('header').text.present?
        message = "<a href='#{link}'>Link To Deck</a><p>"
      else
        message = page.text
      end
    rescue
      if decklink == "/export/4"
        message = "No deck link attatched to this deck yet <p>"
      else
        link = link[0..-10]
        message = "<a href='#{link}'>Link To Deck</a><p>"
      end     
    end

    message
  end

  def self.race_count
    races = Deck.pluck(:race)
    race_groups = races.group_by { |race| race } # {"Druid" => ["Druid", "Druid"]}

    Hash[race_groups.map { |race, list| [race, list.size] }]
  end

  private

  def prepend_http(url)
    url = "http://" + url if URI.parse(url).scheme.nil?

    url
  end
end
