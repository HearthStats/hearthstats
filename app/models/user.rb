class User < ActiveRecord::Base
  rolify
  extend Mailboxer::Models::Messageable::ActiveRecord
  acts_as_messageable
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,:token_authenticatable
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :guest, :userkey, :subscription_id, :authentication_token
  
  ### ASSOCIATIONS:
  
  has_one :profile,       dependent: :destroy
  has_many :arenas,       dependent: :destroy
  has_many :decks,        dependent: :destroy
  has_many :constructeds, dependent: :destroy
  has_many :arena_runs,   dependent: :destroy
  has_many :matches,      dependent: :destroy
  has_many :team_users
  has_many :teams, through: :team_users
  belongs_to :tourny
  belongs_to :subscription
  
  ### CLASS METHODS:
  
  def self.winrate_per_day(user_id_or_ids, days, mode = 'arena')
    mode_id = mode == 'arena' ? 1 : 3
    winrate = Array.new(days, 0)
    
    (0..days).each do |i|
      matches = Match.where(user_id: user_id_or_ids).
                      where(mode_id: mode_id, season_id: Season.current).
                      where("created_at <= ?", i.days.ago.end_of_day)
      win = matches.where(result_id: 1).count
      tot = matches.count
      winrate[i] = [i.days.ago.beginning_of_day.to_i*1000, (win.to_f / tot * 100).round(2)]
    end

    return winrate
  end
  
  ### INSTANCE METHODS:
  
  def get_userkey
    update_attribute(:userkey, SecureRandom.hex) if userkey.nil?
    
    userkey
  end
  
  def name
    return "You should add method :name in your Messageable model"
  end
  
  def mailboxer_email(object)
    nil
  end

  def winrate_per_day(days, mode)
    User.winrate_per_day(id, days, mode)
  end
  
  def is_new?
    (Arena.where(user_id: id).count + Constructed.where(user_id: id).count) == 0
  end
end
