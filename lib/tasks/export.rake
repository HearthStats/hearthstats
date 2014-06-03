namespace :export do
  task :con => :environment do
    matches = Match.where(season_id: 6, mode_id: 3)
    file = "#{Rails.root}/public/#{first.mode.name}_export.csv"
    CSV.open( file, 'w' ) do |writer|
      writer << [ matches.first.mode.name + ' Games']
      writer << [
                  'Class',
                  'Opponent Class',
                  'Result',
                  'Coin?',
                  'Created Time',
                  'Rank'
                ]
      matches.find_each do |match|
        next unless match.user_id
        writer << [
                    match.klass.name,
                    match.oppclass.name,
                    match.result.name,
                    match.coin,
                    match.created_at,
                    match.rank
                  ]
      end
    end
    p "Constructed Matches Exported"
  end

  task :arena => :environment do
    Match.where(season_id: 6, mode_id: 1).to_csv
    p "Constructed Matches Exported"
  end
end