6.times { |i| Season.create num: i + 1 } unless Season.exists?
