class User < ActiveRecord::Base
  rolify
  extend Mailboxer::Models::Messageable::ActiveRecord
  acts_as_messageable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,:token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :guest, :userkey, :subscription_id, :authentication_token, :no_email

  ### VALIDATIONS:
  validates :userkey, uniqueness: true, allow_nil: true

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

  has_many :tournaments, through: :tourn_users
  has_many :tourn_users

  ### CLASS METHODS:

  def self.find_user(identity)
    user = User.find(identity.to_i)
    rescue
    user = User.find_by_email(identity) if user.nil?

    user
  end

  ### INSTANCE METHODS:

  def subscribed?
    !subscription_id.nil?
  end

  def has_permission(role_array)
    role_array.each do |role|
      return true if self.has_role? role
    end
    false
  end

  def blind_drafts
    BlindDraft.where("player1_id = #{self.id} OR player2_id = #{self.id}")
  end

  def get_userkey
    update_attribute(:userkey, SecureRandom.hex) if userkey.nil?

    userkey
  end

  def name
    profile.name.nil? ? email : profile.name
  end

  def mailboxer_email(object)
    if no_email == true
      nil
    else
      email
    end
  end

  def is_new?
    matches.count == 0
  end

  def gen_sig_pic
    p self.id
    if self.profile.nil?
      Profile.create(user_id: self.id)
      return
    end
    new_pic = self.profile.sig_pic_file_name.nil? ? true : false
    matches = self.matches
    con_wr = con_wr(matches)
    arena_wr = arena_wr(matches)
    rank = get_rank(matches)
    p rank
    name = self.profile.name.blank? ? "N/A" : self.profile.name
    pic_info = { name: name,
                const_win_rate: con_wr,
                arena_win_rate: arena_wr,
                ranking: rank,
                legend: false }
    image = ProfileImage.new(pic_info).image.flatten_images
    temp_pic = Tempfile.new(["sig_pic-#{self.id}", '.png'])
    image.write(temp_pic.path)
    self.profile.update_attribute(:sig_pic, temp_pic)

    if new_pic
      Shortener::ShortenedUrl.generate(self.profile.sig_pic.url, self.profile)
    else
      self.profile.shortened_urls.first.update_attribute(:url, self.profile.sig_pic.url)
    end

    p "Sig for #{self.id} updated, view it at: #{self.profile.shortened_urls}"
  end

  def is_admin?
    has_role? :admin
  end

  ### PRIVATE METHODS:

  private

  def arena_wr(matches)
    arena_matches = matches.where(mode_id: 1)
    arena_tot = arena_matches.count
    arena_wr = "N/A"
    unless arena_tot == 0
      arena_wins = arena_matches.where(result_id: 1).count
      arena_wr = (arena_wins.to_f / arena_tot * 100).round(2).to_s
    end

    arena_wr
  end

  def con_wr(matches)
    con_matches = matches.where(mode_id: 3)
    con_tot = con_matches.count
    con_wr = "N/A"
    unless con_tot == 0
      con_wins = con_matches.where(result_id: 1).count
      con_wr = (con_wins.to_f / con_tot * 100).round(2).to_s
    end

    con_wr
  end

  def get_rank(matches)
    rank = matches.includes(:match_rank)
      .includes(match_rank: :rank)
      .where('match_ranks.rank_id IS NOT NULL')
      .last.try(:rank).try(:id)
    rank = 0 if rank.nil?

    rank
  end

end
