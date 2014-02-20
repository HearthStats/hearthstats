class AddAvatarToProfiles < ActiveRecord::Migration
  def self.up
    add_attachment :profiles, :avatar
  end

  def self.down
    remove_attachment :profiles, :avatar
  end
end
