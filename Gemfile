source 'https://rubygems.org'

gem 'rails', '3.2.13'
gem 'rake'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

group :development do
  gem "better_errors", ">= 0.3.2"
  gem "binding_of_caller", ">= 0.6.8"
  gem 'sqlite3'
  gem 'capistrano', "~> 2.14.2"
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false

end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :production do
	gem 'mysql2'
end

gem 'newrelic_rpm'
gem 'slim-rails'
gem 'devise'
gem 'jquery-rails'
gem 'announcements'
gem 'will_paginate', '~> 3.0'
gem 'taps'
gem "nokogiri", "~> 1.6.0"
gem 'social-share-button'
gem 'meta-tags', :require => 'meta_tags'
gem "gibbon", "~> 1.0.4"
gem "figaro"
gem 'jquery-ui-rails'
gem 'dalli'
gem "select2-rails"
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'nprogress-rails'
gem 'sitemap_generator'
gem 'friendly_id'
gem 'impressionist'

gem "rspec-rails", :group => [:test, :development]
gem "factory_girl_rails", :group => [:test, :development]
group :test do
  gem "capybara"
  gem "guard-rspec"
  gem "email_spec"
  gem "database_cleaner", '~> 1.0.1'
  gem "cucumber-rails", :require => false
end

# gem 'activerecord-mysql2-adapter'


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
