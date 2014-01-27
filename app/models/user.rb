class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :guest, :userkey
  # attr_accessible :title, :body
  has_one :profile
  has_many :arenas
  has_many :decks
  has_many :constructeds
  has_many :arena_runs
  belongs_to :tourny

  def get_userkey
  	if self.userkey.nil?
  		self.userkey = SecureRandom.hex
  		self.save!

  		self.userkey
  	else
  		self.userkey
  	end
  end
end
