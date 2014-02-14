class Deck < ActiveRecord::Base
  attr_accessible :loses, :name, :wins, :race, :decklink, :notes, :cardstring, :klass_id, :is_public
  has_many :constructeds

  belongs_to :unique_deck
  belongs_to :klass
  belongs_to :user
  has_many :matches, :through => :match_deck
  has_many :match_deck

  before_save :validate_and_update_stats
  after_save :update_unique_deck_details

  after_destroy :delete_cleanup


  is_impressionable

  extend FriendlyId
  friendly_id :name, use: :slugged

  def delete_cleanup
  	Constructed.destroy_all(:deck_id => self.id)
  	DeckCard.destroy_all(:deck_id => self.id)
  end

  def num_cards
  	return  0 unless self.cardstring
    numCards = 0;
    cards = self.cardstring.split(',')
    cards.each do |cardData|
      chunks = cardData.split('_')
      numCards += chunks[1].to_f
    end
    return numCards
  end

  def validate_and_update_stats

    # check for 30 cards and assign unique deck
    if self.num_cards == 30
      uniqueDeck = UniqueDeck.where(:cardstring => self.cardstring, :klass_id => self.klass_id).first

      # create a new unique deck if needed
      if uniqueDeck.nil?
        uniqueDeck = UniqueDeck.new
        uniqueDeck.cardstring = self.cardstring
        uniqueDeck.klass_id = self.klass_id
        uniqueDeck.save()
      end
      self.unique_deck_id = uniqueDeck.id;

    end
  end

  def update_unique_deck_details
    # re-save the qunique deck on order to trigger
    # proper pulling of data from the first fully
    # saved deck that matches the unique deck's cardstring
    if !self.unique_deck.nil?
      self.unique_deck.save()
    end
  end

  def decklink_message

    # Add http:// to link if not present
    # If page is not a valid link then return link
    # Else return list of cards in deck
    # If Nokogiri fails to parse, return No deck link if blank
    # Else return link
    if !decklink.present?
      message = "No deck link attatched to this deck yet <p>"
    else
    	link = prepend_http(decklink)
	    begin
	      page = Nokogiri::HTML(open(link))
	      if !page.css('header').text.blank?
	        message = "<a href='#{link}'>Link To Deck</a><p>"
	      else
	        message = page.text
	      end
	    rescue
        link = link[0..-10]
        message = "<a href='#{link}'>Link To Deck</a><p>"
      end
    end

    message
  end

  def self.bestuserdeck(userid)
		decks = Deck.where(user_id: userid)
		winrates = Hash.new
		decks.each do |d|
			if d.constructeds.count == 0
			else
				winrates[d.name] = [((d.constructeds.where(win:true).count.to_f / d.constructeds.count)*100).round, d.id]
			end
		end
		deck = winrates.max_by { |x,y| y}
		deck
  end

  def class_name
    if klass.nil?
      return race
    end
    return klass.name
  end

  def num_matches
    return matches.count
  end
  def num_global_matches
    return self.unique_deck.nil? ? 0 : self.unique_deck.num_matches
  end

  def num_minions
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_minions
  end

  def num_spells
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_spells
  end

  def num_weapons
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_weapons
  end

  def wins
    return matches.where(result_id: 1).count
  end
  def global_wins
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_wins
  end

  def losses
    return matches.where(result_id: 2).count
  end
  def global_losses
    return self.unique_deck.nil? ? "-" : self.unique_deck.num_losses
  end

  def winrate
    return num_matches > 0 ? (wins.to_f / num_matches) * 100 : 0
  end
  def global_winrate
    return self.unique_deck.nil? ? "-" : num_global_matches > 0 ? (global_wins.to_f / num_global_matches) * 100 : 0
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
