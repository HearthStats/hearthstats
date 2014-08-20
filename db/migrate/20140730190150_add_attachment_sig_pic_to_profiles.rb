class AddAttachmentSigPicToProfiles < ActiveRecord::Migration
  def self.up
    change_table :profiles do |t|
      t.attachment :sig_pic
    end
  end

  def self.down
    drop_attached_file :profiles, :sig_pic
  end
end
