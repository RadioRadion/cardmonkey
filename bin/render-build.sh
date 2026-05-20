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

echo "Cleaning assets..."
bundle exec rails assets:clean

echo "Building Tailwind CSS..."
bundle exec rails tailwindcss:build

echo "Precompiling assets..."
bundle exec rails assets:precompile RAILS_ENV=production --trace

echo "Verifying asset compilation..."
ls -la public/assets/

# Now handle database operations
unset DISABLE_DATABASE_ENVIRONMENT_CHECK

echo "Setting up database..."
bundle exec rails db:migrate

# Import Scryfall data if needed (commented out by default)
# Uncomment these lines when you want to import fresh data
# bundle exec rails cards:initialize
# bundle exec rails prices:update
