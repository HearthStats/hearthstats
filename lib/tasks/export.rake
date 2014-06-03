namespace :export do
  task :con => :environment do
    Match.where(season_id: 6, mode_id: 3).to_csv
    p "Constructed Matches Exported"
  end

  task :arena => :environment do
    Match.where(season_id: 6, mode_id: 1).to_csv
    p "Constructed Matches Exported"
  end
end