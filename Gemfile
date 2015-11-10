source 'https://rubygems.org'

gem 'rails', '3.2.18'
gem 'rake'
gem 'elasticsearch-model'
gem 'elasticsearch-rails'

group :development do
  gem 'better_errors', '>= 0.3.2'
  gem 'binding_of_caller', '>= 0.6.8'
  gem 'sqlite3'
  gem 'capistrano', '~> 3.4.0'
  # gem 'capistrano-passenger'
  # gem 'capistrano-rvm'
  gem 'capistrano-chruby'
  gem 'capistrano-rails'
  gem 'capistrano-faster-assets', '~> 1.0'
  gem 'capistrano-bundler'
  # gem 'capistrano_rsync_with_remote_cache'
  # gem 'capistrano-local-precompile', require: false
  gem 'turbo-sprockets-rails3'
  gem 'quiet_assets', '>= 1.0.1'
  gem 'rb-fsevent', :require => false
  gem 'seed_dump', :require => false
  gem 'awesome_print', :require => false
  gem 'active_record_query_trace'
  gem 'dotenv-rails'
  gem "thin"
end

group :assets do
# Gems used only for assets and not required
# in production environments by default.
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # gem 'asset_sync'
  gem 'uglifier', '>= 1.0.3'
end

group :production do
  gem 'mysql2'
end

gem 'rubygems-bundler'
# authentication
gem 'devise'
gem 'devise-token_authenticatable'
gem 'cancancan'
gem 'rolify'

# storage
gem 'fog'
gem 'dalli' # Memcache store
gem 'aws-sdk', '~> 1.5.7'
gem 'paperclip', "~> 4.2"

# frontend
gem 'slim-rails'
gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'
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
gem 'commontator', '~> 4.10.0'
gem 'acts_as_votable', '~> 0.10.0'
gem 'unf'
gem 'sanitize'
gem 'acts-as-taggable-on' # Tagging for decks
gem 'gon' # Easy Rails to JS Vars
gem 'ransack' # the new meta_search
gem 'shortener'
gem 'chartkick'
gem 'groupdate'
gem 'announcements'
gem 'rmagick'
# gem 'rack-ssl-enforcer'
gem "squeel"
gem 'pusher'
gem 'sync'
gem 'react-rails', '~> 1.0'
# gem 'unicorn'
gem 'slick_rails'

gem 'ckeditor_rails'
gem 'mechanize', :require => false

# APIs
# gem 'cindy' # Sendy API
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'newrelic_rpm'

# Background
gem 'delayed_job_active_record'
gem 'delayed_job_web'
gem 'daemons'
gem 'whenever'

gem "puma"

platforms :mri do
  gem "skylight"
end

group :test do
  gem 'rspec-rails', '~> 2.12.2'
  gem 'email_spec', '>= 1.4.0'
  gem 'launchy', '>= 2.1.2'
  gem 'capybara', '>= 2.0.2'
  gem 'capybara-screenshot'
  gem 'factory_girl_rails'
  gem 'phashion'
end

group :development, :test do
  gem 'database_cleaner'
  gem 'faker'
end
