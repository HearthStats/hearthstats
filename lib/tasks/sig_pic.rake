namespace :sig_pic do
  desc "Create/update sig_pic for user in the last week"
  task :update => :environment do
    users = User.where('updated_at > ?', 1.day.ago)
    users.each do |user|
      user.gen_sig_pic
    end
    p "Sig Pics Generation Finished"
  end
end
