class GraphGenerator

  attr_reader :matches, :user_klass_ids, :opp_klass_ids

  def initialize(matches, user_klass_ids, opp_klass_ids)
    @matches = matches
    @user_klass_ids = user_klass_ids
    @opp_klass_ids = opp_klass_ids
  end


  def klass_wrs
    klass_wrs = Hash.new
    @user_klass_ids.each do |klass|
      @opp_klass_ids.each do |opp_klass|
        _matches = @matches.select { |match| match.klass_id == klass && 
                                     match.oppclass_id == opp_klass }
        klass_wrs[klass] = {} if klass_wrs[klass].nil?
        klass_wrs[klass][opp_klass] = calculate_winrate(_matches)
      end
    end

    klass_wrs
  end

  def defaults
    {
      :klasses_array => Klass::LIST,
      :beginday => Season.last.begin,
      :endday => Season.last.end
    }
  end

  private

  def calculate_winrate(matches)
    return 0 if matches.size.zero?
    wins = matches.select{|m| m.win?}.size
    wins.to_f / matches.size * 100
  end
end
