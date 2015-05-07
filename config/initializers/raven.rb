require 'raven'

Raven.configure do |config|
  config.dsn = 'http://c74cc59d139340a4a95a25ddbd470eab:9e603aacb4db47bf8e03a17c3af14a74@sentry.hearthstats.net/2'
  config.environments = %w[ production ]
end
