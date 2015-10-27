class UniqueDeckType < ActiveRecord::Base
  attr_accessible :match_string, :archtype_id, :name, :klass_id

  ARCHTYPES = {
    1 => "Aggro",
    2 => "Control",
    3 => "Combo",
    4 => "Midrange",
    5 => "Other"
  }

  ### ASSOCIATIONS:

  has_many :unique_decks
  has_many :decks, through: :unique_decks
  has_many :match_decks, through: :decks

  ### CLASS METHODS:

  def self.get_type_popularity(time_ago)
    query = <<-SQL.strip_heredoc
      SELECT
        `unique_deck_types`.*,
        COUNT(*) as `count_all`
      FROM (
        #{MatchDeck.where('created_at >= ?', time_ago.hours.ago).to_sql}
      ) as `match_decks`
      INNER JOIN `decks`
        ON `decks`.`id` = `match_decks`.`deck_id`
      INNER JOIN `unique_decks`
        ON `unique_decks`.`id` = `decks`.`unique_deck_id`
      INNER JOIN `unique_deck_types`
        ON `unique_deck_types`.`id` = `unique_decks`.`unique_deck_type_id`
      WHERE
        `unique_deck_types`.`name` IS NOT NULL
      GROUP BY
        `unique_deck_types`.`id`
      HAVING
        `count_all` >= 10
    SQL

    recent_deck_types = UniqueDeckType.find_by_sql(query)
    deck_type_count = Hash[recent_deck_types.map { |t| [t.name, t.count_all] }]

    total_valid_matches = deck_type_count.values.sum
    deck_type_count.update(deck_type_count) { |type, matches| matches.to_f/total_valid_matches * 100 }
  end

  def self.get_top_decks
    decks = {}
    arch_pop = Rails.cache.read('archetype_pop').sort_by{|name, val| val}.last(3).reverse

    arch_pop.each do |arch|
      ar = self.get_deck_info(arch[0])
      decks[arch[0]] = ar
    end

    decks
  end

  def self.find_type(klass_id, cardstring)
    klass_types = where(klass_id: klass_id)
    return nil if klass_types.count == 0
    klass_types.each do |deck_type|
      return deck_type.id if match_type(cardstring, deck_type)
    end
  end


  def self.match_type(cardstring, deck_type)
    return nil if deck_type.match_string.nil?
    match_array = deck_type.match_string.split(",")
    matched = true
    match_array.each do |card_id|
      has_card = cardstring.include? card_id
      if !has_card
        matched = false and return
      end
    end

    matched
  end

  def self.find_from_log(args)
    user = args[:user]
    return if args[:log].nil?
    logfile = JSON.parse args[:log]
    if logfile["firstPlayerName"] == user
      playerid = logfile["firstPlayer"]
    else
      playerid = logfile["secondPlayer"]
    end
    card_array = []
    logfile["turns"][0]["actions"].each do |card|
      if card["player"] == playerid
        card_array << Card.find_by_name(card["card"]).try(:id) unless card["card"].blank?
      end
    end
    opp_cardstring = card_array.join(",")
    self.find_type(args[:klass_id], opp_cardstring)

  end

  private

  def self.get_deck_info(arch_name)
    ar = []
    @ar = UniqueDeckType.where(name: arch_name)[0].unique_decks.all.select{ |ud| ud.num_matches != nil && ud.num_matches > 30}.sort!{|ud1, ud2| ud1.winrate <=> ud2.winrate}.reverse
    @ar.each do |ud|
      if ar.count >= 8
        break
      end
      x = ud.decks.all.select{ |deck| [nil, true].include?(deck.is_public) && deck.user_num_matches != nil && deck.user_num_matches >= 30 }.sort! {|ud| ud.user_winrate ? ud.user_winrate : 0 }
      unless x.last(1)[0].nil?
        ar << x.last(1)[0]
      end
    end

    ar
  end
end
