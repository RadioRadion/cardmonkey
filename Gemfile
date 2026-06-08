source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 8.0.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 6.5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 5.0'
# Background job processing
gem 'sidekiq', '~> 7.0'

# Fast, streaming JSON parser for the (multi-GB) Scryfall bulk import
gem 'oj', '~> 3.16'

# Error monitoring
gem 'sentry-ruby'
gem 'sentry-rails'

gem "turbo-rails", "~> 1.5.0"
gem "stimulus-rails", "~> 1.3.0"
gem "tailwindcss-rails", "~> 2.3.0"
gem "importmap-rails"
gem "sprockets-rails"

gem 'rspec-rails'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

gem 'devise'

# convert on user address to lat & long
gem 'geocoder'

# testing mail in development
gem "letter_opener", group: :development

# Font Awesome loaded via CDN in application layout (no sassc dependency)
gem 'simple_form'
gem 'pagy', '~> 6.0'
gem 'down'
gem 'whenever', require: false
gem 'cloudinary'

group :development, :test do
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'dotenv-rails'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rubocop', require: false
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
end

group :test do
  gem 'capybara', '>= 2.15'
  # selenium-webdriver 4.11+ manages drivers itself (Selenium Manager),
  # so the abandoned `webdrivers` gem is no longer needed.
  gem 'selenium-webdriver'
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
