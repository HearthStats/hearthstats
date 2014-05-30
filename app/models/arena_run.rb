class ArenaRun < ActiveRecord::Base
  attr_accessible :class, :gold, :dust, :completed, :user_id, :klass_id, :notes, :complete

  has_many :arenas
  has_many :match_run
  has_many :matches, through: :match_run, dependent: :destroy
  validates :dust, numericality: { greater_than_or_equal_to: 0 }
  validates :gold, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :klass

  before_destroy :delete_all_arena

  def delete_all_arena
    self.matches.delete_all
  end

  def num_wins
    return self.matches.where(result_id: 1).count
  end

  def num_losses
    return self.matches.where(result_id: 2).count
  end

  def self.averageWins(klass_id,userid)
    arena_games = ArenaRun.where(user_id: userid, klass_id: klass_id)
    wins = arena_games.map { |e| e.matches.where( result_id: 1).count }
    average_win = wins.compact.inject{ |sum, el| sum + el }.to_f / wins.size
    average_win = -1 if average_win.nan?

    average_win
  end

  def self.totalGold(userid)
    arena_games = ArenaRun.where(user_id: userid)
    goldamount = arena_games.map { |e| e.gold }
    total_gold = 0
    goldamount.each do |g|
      total_gold += g unless g.nil?
    end
    if total_gold.nil?
      total_gold = 0
    end

    total_gold
  end

  def self.totalDust(userid)
    arena_games = ArenaRun.where(user_id: userid)
    dustamount = arena_games.map { |e| e.dust }
    total_dust = 0
    dustamount.each do |g|
      total_dust += g unless g.nil?
    end
    if total_dust.nil?
      total_dust = 0
    end

    total_dust
  end

  def self.classArray(userid)
    matches = Match.where(user_id: userid, mode_id: 1)
    class_array = Hash.new
    klass_array = Klass.all
    (1..klass_array.count).each do |c|
      class_avgwins = ArenaRun.averageWins(c, userid)
      class_runs = ArenaRun.where( klass_id: c, user_id: userid ).count
      class_winrate = matches.where( klass_id:c ).wins.count.to_f / matches.where(klass_id: c).count
      class_coinrate = matches.where( klass_id: c, coin: true ).wins.count.to_f / matches.where( klass_id: c, coin: true).count
      class_nocoinrate = matches.where( klass_id: c,  coin: false ).wins.count.to_f / matches.where( klass_id: c, coin: false).count

      class_array[Klass.find(c)[:name]] = [["Average wins", class_avgwins],
                        ["Total runs with class", class_runs],
                        ["Class winrate", class_winrate],
                        ["Win rate with coin", class_coinrate],
                        ["Win rate without coin", class_nocoinrate]]
    end

    class_array
  end

  def self.distribution_array
    arena_dist = Array.new
    Klass.all.each do |klass|
      ArenaRun.where(user_id: current_user, klass_id: klass.id).each do |run|
        arena_dist[run.matches.where(result_id: 1).length] += 1
      end
      area_dist.each_with_index do |a,i|
        total_array << [i, arena_dist[i]]
      end
      raise
    end
  end
end
