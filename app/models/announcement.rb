class Announcement < ActiveRecord::Base
  attr_accessible :body

  ### VALIDATIONS:

  validates_presence_of :body

  ### CLASS METHODS:

  def self.newest
    Announcement.last
  end

  def self.newest_private
    Announcement.where("type is null").order("id desc").first
  end

  def self.newest_public
    Announcement.where("type = 'public'").order("id desc").first
  end

end
