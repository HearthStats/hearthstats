require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper
task :NewCards => :environment do

  require 'json'

  file = File.read(Rails.root.join('public', 'naxx.json'))

  json = JSON.parse(file)
  rarity = {"Legendary" => 5, "Epic" => 4, "Rare" => 3, "Common" =>2, "Free" => 1}
  counter = 0
  json.each do |q|
    next unless q["id"][0,2] == "FP"
    Card.create(
                name: q["name"],
                description: q["text"],
                attack: q["attack"].to_i,
                health: q["health"].to_i,
                mana: q["cost"].to_i,
                card_set_id: 3,
                rarity_id: rarity[q["rarity"]],
                klass_id: klasses_hash[q["playerClass"]],
                blizz_id: q["id"]
               )
    counter += 1
  end
  puts counter.to_s + " Cards Imported"
end

task :RenameCards => :environment do
  p "Renaming Files"

  folder_path = "/Users/trigun0x2/Dropbox/Projects/hearthstats/public/naxx_pics"
  Dir.glob(folder_path + "/*").sort.each do |f|
    filename = File.basename(f, File.extname(f))
    p filename
    File.rename(f, folder_path + "/" +
                Card.where(blizz_id: filename).first.name.parameterize +
                File.extname(f))
  end
end

task :add_blizz_id=> :environment do

  require 'json'

  file = File.read(Rails.root.join('public', 'AllSets.json'))

  json = JSON.parse(file)
  counter = 0
  json.flatten(2).each do |q|
   next unless q["id"]
   card = Card.find_by_name(q["name"])
   next if card.nil?
   card.blizz_id = q["id"]
   card.save!
   counter += 1
  end
  puts counter.to_s + " Cards Modified"
end

task :fix_blizz_id=> :environment do
  # Stupid Cold Bloooooood
  # Fix cold blood blizz_id
  Card.find(196).update_attribute(:blizz_id, "CS2_073")
  Card.find(109).update_attribute(:blizz_id, "NEW1_029")
  Card.find(203).update_attribute(:blizz_id, "NEW1_040")
  Card.find(356).update_attribute(:blizz_id, "EX1_614")
  Card.find(296).update_attribute(:blizz_id, "EX1_100")
  Card.find(117).update_attribute(:blizz_id, "EX1_014")
  Card.find(46).update_attribute(:blizz_id, "CS2_008")
  Card.all.each do |card|
    if letter?(card.blizz_id)
      p card.id 
      wrong_blizz_id = card.blizz_id.split("")
      corrected_blizz_id = wrong_blizz_id
      wrong_blizz_id.reverse.each do |char|
        if numeric?(char)
          break
        else
          corrected_blizz_id.pop
        end
      end
      card.blizz_id = corrected_blizz_id.join
      card.save
    end
  end
end

task :scrape_card_images=> :environment do
  require 'mechanize'
  Card.all.each do |card|
    begin
      link = "http://wow.zamimg.com/images/hearthstone/cards/enus/original/#{card.blizz_id}.png"
      agent.get(link).save_as "/Users/trigun0x2/Dropbox/Projects/cards/#{card.name.parameterize}.png"
    rescue
      puts card.name
    end
  end
  p "Big Bro, The job is done."
end

def letter?(lookAhead)
  lookAhead =~ /[[:alpha:]]/
end

def numeric?(lookAhead)
  lookAhead =~ /[[:digit:]]/
end