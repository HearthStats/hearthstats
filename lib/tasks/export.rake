namespace :export do
  task :con => :environment do
    matches = Match.where(season_id: 6, mode_id: 3)
    file = "#{Rails.root}/public/ranked_export_#{Time.now.strftime('%d_%m_%Y')}.csv"
    CSV.open( file, 'w' ) do |writer|
      writer << [ matches.first.mode.name + ' Games']
      writer << [
                  'User Hash',
                  'Class',
                  'Opponent Class',
                  'Result',
                  'Coin?',
                  'Created Time',
                  'Rank'
                ]
      matches.find_each do |match|
        next unless match.user_id
        if match.rank.nil?
          writer << [
                      Digest::SHA1.hexdigest(match.user.id.to_s),
                      match.klass.name,
                      match.oppclass.name,
                      match.result.name,
                      match.coin,
                      match.created_at,
                    ]
        else
          writer << [
                      Digest::SHA1.hexdigest(match.user.id.to_s),
                      match.klass.name,
                      match.oppclass.name,
                      match.result.name,
                      match.coin,
                      match.created_at,
                      match.rank.id
                    ]
        end
      end
    end
    p "Constructed Matches Exported"
  end

  task :arena => :environment do
    Match.where(season_id: 6, mode_id: 1).to_csv
    p "Constructed Matches Exported"
  end
end