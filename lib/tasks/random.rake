task :greet => :environment do
	users = User.all
	users.each do |u|
		puts u.email
	end
end

task :fix_profiles => :environment do
	users = User.includes(:profile).where(guest: nil).where( :profiles => { :user_id => nil } )
	users.each do |u|
		profile = Profile.new
    profile.user_id = u.id
    profile.save
	end
end

task :delete_guest => :environment do
	User.destroy_all(:guest => true)
end