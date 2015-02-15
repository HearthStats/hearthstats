class ActiveRecord::Base
  def calculate_winrate(matches)
    return 0 if matches.size.zero?
    wins = matches.select{|m| m.win?}.size
    wins.to_f / matches.size * 100
  end
end
