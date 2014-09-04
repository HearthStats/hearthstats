# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :output, "/var/www/hearthstats/current/log/cron_log.log"
env :PATH, ENV['PATH']

every 5.hours do
  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake cron:welcome_cache"
end

every 2.hours do
  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake cron:expire_top_decks"
end

every 5.minutes do
  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake cron:expire_recent_decks"
end
