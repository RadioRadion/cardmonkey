# Use whenever to define cron jobs
# Learn more: http://github.com/javan/whenever

# Set path for cron output logging
set :output, "#{path}/log/cron.log"

# Environment variables
env :PATH, ENV['PATH']
set :environment, :production

# Scryfall data sync and price updates at 4 AM
# This includes:
# 1. Download latest Scryfall bulk data
# 2. Initialize/update cards and versions
# 3. Update prices
every 1.day, at: '4:00 am' do
  rake "scryfall:sync"
end

# Cleanup old backups weekly
every :sunday, at: '5:00 am' do
  rake "scryfall:cleanup_backups"
end
