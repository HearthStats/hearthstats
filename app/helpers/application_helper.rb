module ApplicationHelper
  def current_season
    Season.last.id
  end

  def klasses_hash
    klasses = Hash.new
    Klass.all.each do |k|
      klasses[k.name] = k.id
    end

    klasses
  end

  def get_name(match, table)
    id = match.send table.downcase+"_id"
    table = "Klass" if table == "Oppclass"
    table = "MatchResult" if table == "Result"
    result = table.constantize.find(id).name

    result
  end


end
