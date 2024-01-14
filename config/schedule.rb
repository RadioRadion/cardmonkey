# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

#every 1.day, at: '11:30 am' do
#  rake "data:fetchCards"
 # rake "data:fetchWants"
#end

every 1.day, at: '2:45 am' do
  command "wget -O /Users/valentinlassartesse/code/RadioRadion/cardmonkey/tmp/scryfall/all-cards.json https://data.scryfall.io/all-cards/all-cards-20240108221542.json"
end

every 1.day, at: '3:00 am' do
  runner "UpdatePricesTask.perform"
end

