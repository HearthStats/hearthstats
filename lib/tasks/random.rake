task :greet => :environment do
	users = User.all
	users.each do |u|
		puts u.email
	end
end