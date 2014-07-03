class ArenaRun < ActiveRecord::Base
  attr_accessible :class, :gold, :dust, :completed, :user_id, :klass_id, :notes, :complete

  ### ASSOCIATIONS:
  
  has_many :arenas
  has_many :match_runs
  has_many :matches, through: :match_runs, dependent: :destroy
  belongs_to :klass
   
  ### VALIDATIONS:
  
  validates :dust, numericality: { greater_than_or_equal_to: 0 }
  validates :gold, numericality: { greater_than_or_equal_to: 0 }

  ### CLASS METHODS:
  
  def self.average_wins(klass_id, userid)
    runs = ArenaRun.where(user_id: userid, klass_id: klass_id)
    return -1 if runs.blank?
    wins = runs.sum { |r| r.matches.wins.count }
    
    wins.to_f / runs.count
  end

  def self.total_gold(userid)
    ArenaRun.where(user_id: userid).sum(:gold)
  end

  def self.total_dust(userid)
    ArenaRun.where(user_id: userid).sum(:dust)
  end

  def self.classArray(userid)
    matches = Match.where(user_id: userid, mode_id: 1)
    class_array = Hash.new
    klass_array = Klass.all
    (1..klass_array.count).each do |c|
      class_avgwins = ArenaRun.average_wins(c, userid)
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
  
  ### INSTANCE METHODS:
  
  def num_wins
    matches.wins.count
  end

  def num_losses
    matches.losses.count
  end


end
