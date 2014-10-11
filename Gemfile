source 'https://rubygems.org'

gem 'rails', '3.2.18'
gem 'rake'

group :development do
  gem 'better_errors', '>= 0.3.2'
  gem 'binding_of_caller', '>= 0.6.8'
  gem 'sqlite3'
  gem 'capistrano', '~> 2.14.2'
  gem 'capistrano_rsync_with_remote_cache'
  gem 'quiet_assets', '>= 1.0.1'
  gem 'rb-fsevent', :require => false
  gem 'pry'
  gem 'pry-byebug'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard-spring'
  gem 'seed_dump'
  gem 'rack-mini-profiler'
  gem 'awesome_print', :require => false
  #gem 'active_record_query_trace'
end

group :assets do
# Gems used only for assets and not required
# in production environments by default.
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'turbo-sprockets-rails3'
  # gem 'asset_sync'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'mysql2'
end

# authentication
gem 'devise'
gem 'devise-token_authenticatable'
gem 'cancancan'
gem 'rolify'

# storage
gem 'fog'
gem 'dalli' # Memcache store
gem 'aws-sdk'
gem 'paperclip'

# frontend
gem 'slim-rails'
gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'
gem 'taps'
gem 'nokogiri'
gem 'social-share-button'
gem 'meta-tags', :require => 'meta_tags'
gem 'figaro'
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0.0'
# gem 'turbolinks'
# gem 'jquery-turbolinks' # Fixes JS for turbolinks
# gem 'nprogress-rails' # Progress bar for turbolinks
gem 'sitemap_generator'
gem 'friendly_id' # Better urls for deck
gem 'impressionist' # Track number of times profiles/decks are viewed
gem 'feedjira', :require => false # Parse rss feeds
gem 'lograge' # Minify log outputs
gem 'httparty' # Make them http requests easily
gem 'select2-rails'
gem 'opinio' # Comment system
gem 'unf'
gem 'mailboxer', '~> 0.11.0' # User notifications and mailing
gem 'thin'
gem 'meta_search',    '>= 1.1.0.pre' # For active admin
gem 'sanitize'
gem 'acts-as-taggable-on' # Tagging for decks
gem 'gon' # Easy Rails to JS Vars
gem 'ransack' # the new meta_search
gem 'shortener'
gem 'chartkick'
gem 'groupdate'
gem 'sync'
gem 'announcements'
gem 'bootstrap-wysihtml5-rails'
gem 'rmagick'
gem 'public_activity'

# APIs
gem 'newrelic_rpm'
gem 'cindy' # Sendy API
gem 'appsignal'
gem 'skylight'
gem 'pusher'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'

# Background
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons'
gem 'whenever'

group :test do
  gem 'rspec-rails', '~> 2.12.2'
  gem 'email_spec', '>= 1.4.0'
  gem 'launchy', '>= 2.1.2'
  gem 'capybara', '>= 2.0.2'
  gem 'capybara-screenshot'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'phashion'
end

group :development, :test do
  gem 'database_cleaner'
  gem 'faker'
end
