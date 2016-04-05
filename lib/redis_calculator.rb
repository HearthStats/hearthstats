require 'redis'

class RedisCalc
  def initialize
    @redis = $redis
  end

  def get_wr_all_klass_daysback(mode_id, days=0, include_draws=true, sort_by_wr=false)
    date_wrs = {}
    (0..days).each do |days_back|
      klass_wr = {}
      redis_date = days_back.days.ago.end_of_day.strftime("%d_%m_%Y")
      key = "#{mode_id}_#{redis_date}"
      date_key = days_back.days.ago.beginning_of_day
      winrates = $redis.hgetall(key)
      Klass::LIST.each do |klass_id, klass_name|
        wins = winrates["#{klass_id}_1"]
        total = wins.to_i + winrates["#{klass_id}_2"].to_i
        total += winrates["#{klass_id}_3"].to_i if include_draws
        winrate = (wins.to_f/total * 100).round(2)
        klass_wr[klass_id] = winrate
      end
      klass_wr.reject! { |klass, wr| wr.is_a?(Float) && wr.nan? }
      if sort_by_wr
        date_wrs[date_key] = klass_wr.sort_by {|klass, wr| wr}.reverse.to_h
      else
        date_wrs[date_key] = klass_wr
      end
    end
    # if mode_id == 3
    #   Rails.cache.delete("con#wr_rate-#{klass_id}")
    #   Rails.cache.write("con#wr_rate-#{klass_id}", klass_wr)
    # elsif mode_id == 1
    #   Rails.cache.delete("arena#wr_rate-#{klass_id}")
    #   Rails.cache.write("arena#wr_rate-#{klass_id}", klass_wr)
    # end

    date_wrs
  end

  def get_wr(klass_id, mode_id, days_ago=0)
    redis_date = days_ago.days.ago.end_of_day.strftime("%d_%m_%Y")
    key = "#{mode_id}_#{redis_date}"
    wins = $redis.hget(key, "#{klass_id}_1")
    draws = $redis.hget(key, "#{klass_id}_3")
    losses = $redis.hget(key, "#{klass_id}_2")
    total = wins.to_i + draws.to_i + losses.to_i

    (wins.to_f/total * 100).round(2)
  end

end
