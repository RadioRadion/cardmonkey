#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Ruby dependencies
bundle install

# Install JavaScript dependencies
npm install

# Cleanup any assets from previous deploys
rm -rf public/assets

# Build assets without accessing the database
export RAILS_ENV=production
export SECRET_KEY_BASE=dummy
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1

# Ensure Tailwind CSS is built first
bundle exec rails tailwindcss:install
bundle exec rails tailwindcss:build

# Then handle other assets
bundle exec rails assets:clean
bundle exec rails assets:precompile --trace

# Now handle database operations
unset DISABLE_DATABASE_ENVIRONMENT_CHECK

echo "Checking database migration status..."
bundle exec rails db:migrate:status || true

echo "Resetting and rebuilding database..."
bundle exec rails db:drop db:create db:schema:load db:migrate DISABLE_DATABASE_ENVIRONMENT_CHECK=1

# Import Scryfall data if needed (commented out by default)
# Uncomment these lines when you want to import fresh data
# bundle exec rails cards:initialize
# bundle exec rails prices:update
