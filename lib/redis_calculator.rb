require 'redis'

class RedisCalc
  def initialize
    @redis = $redis
  end

  def get_wr_all_klass_daysback(mode_id, days=1, include_draws=true)
    klass_wr = {}
    (0..days).each do |days_back|
      redis_date = days_back.days.ago.end_of_day.strftime("%d_%m_%Y")
      key = "#{mode_id}_#{redis_date}"
      date_key = days_back.ago.beginning_of_day
      winrates = $redis.hgetall(key)
      Klass::LIST.each do |klass_id, klass_name|
        wins = winrates["#{klass_id}_1"]
        total = wins.to_i + winrates["#{klass_id}_2"].to_i
        total += winrates["#{klass_id}_3"].to_i if include_draws
        winrate = (wins.to_f/total * 100).round(2)
        klass_wr[date_key] = winrate
      end
    end
    # if mode_id == 3
    #   Rails.cache.delete("con#wr_rate-#{klass_id}")
    #   Rails.cache.write("con#wr_rate-#{klass_id}", klass_wr)
    # elsif mode_id == 1
    #   Rails.cache.delete("arena#wr_rate-#{klass_id}")
    #   Rails.cache.write("arena#wr_rate-#{klass_id}", klass_wr)
    # end

    klass_wr
  end
end
