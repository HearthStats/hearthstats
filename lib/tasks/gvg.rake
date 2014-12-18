namespace :gvg do
  require "#{Rails.root}/app/helpers/application_helper"
  include ApplicationHelper

  desc "Outputs stats per card in GvG"
  task :per_card_stats => :environment do
    cards = Card.includes(:unique_decks).where("id > ?", 561)

    file = "#{Rails.root}/public/gvg_cards.csv"
    CSV.open( file, 'w') do |writer|
      cards.each do |card|
        writer << [card.name, 
                   card.unique_decks.where('num_matches > ?', 0).average(:winrate), 
                   card.unique_decks.count]
      end
    end
  end
end
