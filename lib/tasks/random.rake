task :greet => :environment do
	users = User.all
	users.each do |u|
		puts u.email
	end
end

task :fix_profiles => :environment do
	users = User.includes(:profile).where(guest: nil).where( :profiles => { :user_id => nil } )
	counter = 0
	users.each do |u|
		profile = Profile.new
    profile.user_id = u.id
    profile.save
    counter += 1
	end
	puts "#{counter} profiles fixed"
end

task :delete_guest => :environment do
	count = User.where(:guest => true).count
	User.destroy_all(:guest => true)

	puts "#{count} Guests Deleted"
end