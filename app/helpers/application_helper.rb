module ApplicationHelper
  def current_season
    Season.last.id
  end

  def klasses_hash
    klasses = Hash.new
    Klass.all.each do |k|
      klasses[k.name] = k.id
    end
  end
end
