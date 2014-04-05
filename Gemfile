source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'rake'

group :development do
  gem "better_errors", ">= 0.3.2"
  gem "binding_of_caller", ">= 0.6.8"
  gem 'sqlite3'
  gem 'capistrano', "~> 2.14.2"
  gem 'capistrano_rsync_with_remote_cache'
  gem "quiet_assets", ">= 1.0.1"
  gem 'rb-fsevent', :require => false
  gem 'thin'
  gem 'pry'
end

group :assets do
# Gems used only for assets and not required
# in production environments by default.
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'turbo-sprockets-rails3'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :production do
	# gem "asset_sync"
	gem 'mysql2'
end

gem 'slim-rails'
gem 'devise'
gem 'jquery-rails'
gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'
gem 'taps'
gem "nokogiri"
gem 'social-share-button'
gem 'meta-tags', :require => 'meta_tags'
gem "figaro"
gem 'jquery-ui-rails'
gem 'dalli' # Memcache store
gem 'turbolinks'
gem 'jquery-turbolinks' # Fixes JS for turbolinks
gem 'nprogress-rails' # Progress bar for turbolinks
gem 'sitemap_generator'
gem 'friendly_id' # Better urls for deck
gem 'impressionist' # Track number of times profiles/decks are viewed
gem 'feedzirra' # Parse rss feeds
gem 'twitch' # Get Twitch streamers
gem "lograge" # Minify log outputs
gem 'redactor-rails' # WYSIWYG editor
gem 'rmagick' # Upload images needed for redactor
gem 'carrierwave' # Upload files needed for redactor
gem 'mini_magick' # Upload images needed for redactor
gem 'cindy' # Sendy API
gem 'httparty' # Make them http requests easily
gem 'paperclip'
gem 'aws-sdk'
gem "select2-rails"
gem "opinio" # Comment system
gem "kaminari"
gem "fog"
gem 'unf'
gem "cancan"
gem 'mailboxer' # User notifications and mailing
gem 'imgkit'
gem 'rollbar'

group :test do
  gem 'rspec-rails', '>= 2.12.2'
  gem 'database_cleaner', '>= 0.9.1'
  gem 'email_spec', '>= 1.4.0'
  gem 'cucumber-rails', '>= 1.3.0'
  gem 'launchy', '>= 2.1.2'
  gem "capybara", ">= 2.0.2"
  gem "factory_girl_rails", ">= 4.2.0"
end
# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# To use debugger
# gem 'debugger'

