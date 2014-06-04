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
  
  has_one :profile, dependent: :destroy
  has_many :arenas, dependent: :destroy
  has_many :decks, dependent: :destroy
  has_many :constructeds, dependent: :destroy
  has_many :arena_runs, dependent: :destroy
  has_many :matches, dependent: :destroy
  has_many :team_users
  has_many :teams, through: :team_users
  belongs_to :tourny
  belongs_to :subscription
  
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

  def is_new?
    (Arena.where(user_id: id).count + Constructed.where(user_id: id).count) == 0
  end
  
end
