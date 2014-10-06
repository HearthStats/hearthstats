class Announcement < ActiveRecord::Base

  validates_presence_of :body
  attr_accessible :heading, :body
  
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
