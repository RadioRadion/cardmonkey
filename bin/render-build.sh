#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install

# Cleanup any assets from previous deploys
rm -rf public/assets

# Compile assets
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# Import Scryfall data if needed (commented out by default)
# Uncomment these lines when you want to import fresh data
# bundle exec rails cards:initialize
# bundle exec rails prices:update
