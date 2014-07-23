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


