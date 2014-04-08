rails_env = ENV['RAILS_ENV'] || 'development'

threads 4,4

bind  "unix:///Users/trigun0x2/Dropbox/Projects/hearthstats/tmp/puma.sock"
pidfile "/Users/trigun0x2/Dropbox/Projects/hearthstats/tmp/pid"
state_path "/Users/trigun0x2/Dropbox/Projects/hearthstats/tmp/state"

activate_control_app
