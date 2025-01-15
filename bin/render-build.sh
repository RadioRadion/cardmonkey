#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
npm install

# Cleanup any assets from previous deploys
rm -rf public/assets

# Build assets
export RAILS_ENV=production
export SECRET_KEY_BASE=dummy

# Ensure Tailwind CSS is built first
bundle exec rails tailwindcss:install
bundle exec rails tailwindcss:build

# Then handle other assets
bundle exec rails assets:clean
bundle exec rails assets:precompile

# Run database migrations
bundle exec rails db:migrate

# Import Scryfall data if needed (commented out by default)
# Uncomment these lines when you want to import fresh data
# bundle exec rails cards:initialize
# bundle exec rails prices:update
