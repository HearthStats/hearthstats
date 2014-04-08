rails_env = ENV['RAILS_ENV'] || 'development'

threads 4,4
if rails_env == 'development'
	bind  "unix:///Users/trigun0x2/Dropbox/Projects/hearthstats/tmp/puma.sock"
	pidfile "/Users/trigun0x2/Dropbox/Projects/hearthstats/tmp/pid"
	state_path "/Users/trigun0x2/Dropbox/Projects/hearthstats/tmp/state"
else
	bind  "unix:///var/www/hearthstats/current/tmp/puma.sock"
	pidfile "/var/www/hearthstats/current/tmp/pid"
	state_path "/var/www/hearthstats/current/tmp/state"
end

activate_control_app
