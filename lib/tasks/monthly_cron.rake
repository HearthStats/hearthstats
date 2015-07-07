task :update_season => :environment do
  date_today = Date.today.strftime("%d")
  if date_today == "01"
    current_season = Season.last.num
    Season.create(num: current_season + 1)
  end
end