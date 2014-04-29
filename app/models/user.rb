class User < ActiveRecord::Base
  rolify
	extend Mailboxer::Models::Messageable::ActiveRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,:token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :guest, :userkey, :subscription_id, :authentication_token

  has_one :profile, dependent: :destroy
  has_many :arenas, dependent: :destroy
  has_many :decks, dependent: :destroy
  has_many :constructeds, dependent: :destroy
  has_many :arena_runs, dependent: :destroy
  belongs_to :tourny
  has_many :matches, dependent: :destroy
  belongs_to :subscription

  acts_as_messageable
  has_many :team_users
  has_many :teams, through: :team_users

  def get_userkey
  	if self.userkey.nil?
  		self.userkey = SecureRandom.hex
  		self.save!

  		self.userkey
  	else
  		self.userkey
  	end
  end

  def name
	  return "You should add method :name in your Messageable model"
	end

  def mailboxer_email(object)
	  nil
	end

end
