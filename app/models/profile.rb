class Profile < ActiveRecord::Base
  attr_accessible :bnetid, :name, :private, :bnetnum, :time_zone, :avatar, :user_id, :sig_pic
  
  is_impressionable
  
  has_shortened_urls

  ### ASSOCIATIONS:
  
  belongs_to :users
  
  has_attached_file :avatar, :default_url => "/assets/avatar.jpg", styles:{
    thumb: '29x29>',
    square: '200x200#',
    medium: '300x300>'
  }

  has_attached_file :sig_pic, :default_url => "/assets/sig_pic.png"
  
  ### VALIDATIONS:
  
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
  validates_attachment_content_type :sig_pic, :content_type => /\Aimage\/.*\Z/
  
end
