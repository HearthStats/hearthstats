module SearchHelper
  def calculate_winrate(matches)
    return 0 if matches.size.zero?
    wins = matches.select{|m| m.win?}.size
    wins.to_f / matches.size * 100
  end

  def default_params
    {
      "klass_id_in" => Klass.all_klasses.map(&:id),
      "oppclass_id_in" => Klass.all_klasses.map(&:id),
      "coin_in" => [true, false],
      "created_at_gteq" => 30.days.ago.to_s(:db)
    }
  end

  def default_options
    {
      :q => {},
      :items => 20,
      :page => 1,
      :sort => 'created_at',
      :order => 'desc'
    }
  end
end
