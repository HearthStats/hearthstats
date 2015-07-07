namespace :deck_importer do
  task :hearthstonetopdecks => :environment do
    scraper = DeckScraper.new
    decks = scraper.get_decks
    binding.pry
  end
end
