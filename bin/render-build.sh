#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
npm install

# Cleanup any assets from previous deploys
rm -rf public/assets

# Build Tailwind CSS with debugging
RAILS_ENV=production bundle exec rails tailwindcss:build
echo "Checking for tailwind.css after build:"
ls -la app/assets/builds/

# Compile assets with debugging
RAILS_ENV=production bundle exec rails assets:precompile
echo "Checking compiled assets:"
ls -la public/assets/

# Run database migrations
bundle exec rails db:migrate

# Import Scryfall data if needed (commented out by default)
# Uncomment these lines when you want to import fresh data
# bundle exec rails cards:initialize
# bundle exec rails prices:update
