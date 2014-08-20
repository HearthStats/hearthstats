namespace :sig_pic do
  desc "Create/update sig_pic for user in the last week"
  task :create => :environment do
    users = User.where('last_sign_in_at > ?', 5.days.ago)
    users.each do |user|
      user.gen_sig_pic
    end
  end
end
