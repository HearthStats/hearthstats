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

every 1.day do
  # command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake sig_pic:update"
  # command "echo '--------------------------'"
  # command "echo 'Sigs Update'"
  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake update_season"
  command "echo '--------------------------'"
  command "echo 'Changed to new Season'"
  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake cron:rank_class"
  command "echo '--------------------------'"
  command "echo 'Rank Class Updated'"
  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake deck_importer:hearthstonetopdecks"
  command "echo '--------------------------'"
  command "echo 'Scrape Decks'"
  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake cron:top_decks"
  command "echo '--------------------------'"
  command "echo 'Refreshing Top Decks"
end

every 5.hours do
  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake cron:welcome_cache"
  command "echo '--------------------------'"
  command "echo 'Welcome Cache'"
end

every 2.hours do
  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake cron:expire_top_decks"
  command "echo '--------------------------'"
  command "echo 'Expire Top Decks'"

  command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake cron:archetype_pop"
  command "echo '--------------------------'"
  command "echo 'Refreshing Archetypes'"

  # command "cd /var/www/hearthstats/current/ && RAILS_ENV=production bundle exec rake cron:archetype_decks"
  # command "echo '--------------------------'"
  # command "echo 'Refreshing Archetype Decks'"
end